import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:image_picker/image_picker.dart';

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
  late UserProfile? _userProfile;
  File? _profileImage;
  // bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _userProfile = widget.userProfile;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera); // oder .gallery

    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser!;
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

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
      } catch (error) {
        debugPrint('Bild-Upload fehlgeschlagen: $error');
      }
    }

    final updatedProfile = _userProfile!.copyWith(photoUrl: photoUrl);
    
    await ref.read(userProfileProvider.notifier).saveProfile(updatedProfile);
    
    if (mounted) Navigator.of(context).pop(updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    final config = AppScreenConfig(
      title: 'Profil bearbeiten',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: _saveProfile,
        ),
      ],
    );
    
    // if (_isLoading) {
    //  return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    final validPhotoUrl = _userProfile?.photoUrl != null && _userProfile!.photoUrl!.startsWith('http');
    
    return AppScaffold(
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
                  border: OutlineInputBorder(),
                ),
                initialValue: _userProfile?.displayName ?? "",
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
    );
  }
}
