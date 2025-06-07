import {onDocumentWritten} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const updateLoggedTime = onDocumentWritten(
  "users/{userId}/{collectionName}/{taskId}/executions/{executionId}",
  async (event) => {
    const {userId, collectionName, taskId} = event.params;

    const executionsSnapshot = await db
      .collection(`users/${userId}/${collectionName}/${taskId}/executions`)
      .get();

    let totalDurationMs = 0;

    executionsSnapshot.forEach((doc) => {
      const data = doc.data();
      const start = data.start?.toDate?.() ?? new Date(data.start);
      const end = data.end?.toDate?.() ?? new Date(data.end);
      totalDurationMs += end.getTime() - start.getTime();
    });

    const totalMinutes = Math.floor(totalDurationMs / 60000);

    await db
      .collection(`users/${userId}/${collectionName}`)
      .doc(taskId)
      .update({loggedTime: totalMinutes});

    console.log(
      `Updated loggedTime for task ${taskId} to ${totalMinutes} minutes.`
    );
  }
);
