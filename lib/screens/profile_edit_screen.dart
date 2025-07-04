import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:aspira/models/user_profile.dart';
import 'package:aspira/providers/user_profile_provider.dart';
import 'package:aspira/utils/appscreenconfig.dart';
import 'package:aspira/utils/appscaffold.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({
    super.key,
    required this.userProfile,
    });

  final UserProfile userProfile;

  @override
  ConsumerState<ProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserProfile _userProfile;
  File? _profileImage;
  bool _isSaving = false;
  // bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
    debugPrint('✅ _userProfile initialisiert über Konstruktor');
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();

    if (!mounted) return; // Kontext-Schutz

    if (status.isGranted) {    
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera); // oder .gallery

      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Zeige Dialog, um User zur Einstellungsseite zu führen
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kamerazugriff benötigt'),
          content: const Text('Bitte erlaube den Kamerazugriff in den Einstellungen.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Einstellungen öffnen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Abbrechen'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    
    debugPrint('💾 Speichervorgang gestartet mit UserProfile: $_userProfile');

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser!;
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      setState(() {
        _isSaving = false;
      });
      return;
    }

    _formKey.currentState!.save();

    String? photoUrl = _userProfile!.photoUrl;
    if (_profileImage != null) {
      final ref = FirebaseStorage.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('profile.jpg');
      
      try {
        await ref.putFile(_profileImage!);
        photoUrl = await ref.getDownloadURL();
      } catch (error, stackTrace) {
        debugPrint('Bild-Upload fehlgeschlagen: $error');
        debugPrint('StackTrace: $stackTrace');
      }
    }

    final updatedProfile = _userProfile!.copyWith(photoUrl: photoUrl);    
    await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);
    
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      debugPrint('🔙 Profil gespeichert, kehre zurück mit updatedProfile: $updatedProfile');
      Navigator.of(context).pop(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    debugPrint('📍 Build gestartet – extra: $extra');

    final config = AppScreenConfig(
      title: 'Profil bearbeiten',
      appBarActions: [
        _isSaving
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
      ],
    );
    
    // if (_isLoading) {
    //  return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    final validPhotoUrl = _userProfile?.photoUrl != null && _userProfile!.photoUrl!.startsWith('http');
    
    return PopScope<Object?>(
      canPop: !_isSaving, // Pop wird blockiert, wenn _isSaving == true
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop && _isSaving) {
          // User wollte gehen, aber Pop wurde blockiert
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil wird gespeichert. Bitte warten'),
            ),
          );
        }
      },
      child: AppScaffold(
        config: config,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _profileImage != null 
                    ? FileImage(_profileImage!)
                    : validPhotoUrl
                      ? NetworkImage(_userProfile!.photoUrl!) as ImageProvider
                      : null,
                  child: _profileImage == null && !validPhotoUrl
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Benutzername',
                  ),
                  initialValue: _userProfile?.displayName ?? "",
                  maxLength: 25,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Mindestens 3 Zeichen erforderlich.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userProfile = _userProfile!.copyWith(displayName: value!.trim());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
