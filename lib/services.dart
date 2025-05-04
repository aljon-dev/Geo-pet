import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Services {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Error signing in: $e');
      throw e; // re-throw the error to handle in UI
    }
  }

  Future<UserCredential?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return null;
      }

      final String uid = user.uid;
      final String email = user.email ?? '';
      final String displayName = user.displayName ?? '';
      final List<String> nameParts = displayName.split(' ');
      final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Check if the user already exists
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        // If not, create a new record
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'firstname': firstName,
          'lastname': lastName,
          'age': '',
          'contact': '',
          'address': '',
          'images': '',
          'type': 'customer',
          'email': email,
        });
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signUp(
      String firstname, String lastname, String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'age': '',
        'contact': '',
        'address': '',
        'images': '',
        'images2': '',
        'images3': '',
        'type': 'member',
      });
    } catch (e) {
      print('Error signing up: $e');
      throw e;
    }
  }

  Future<void> updateProfile(
      String uid,
      String firstname,
      String lastname,
      String age,
      String contact,
      String address,
      String images,
      String images2,
      String images3,
      String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstname': firstname,
        'lastname': lastname,
        'age': age,
        'contact': contact,
        'address': address,
        'images': images,
        'images2': images2,
        'images3': images3,
        'type': 'customer',
        'email': email,
      });
    } catch (e) {
      print('Error updating profile: $e');
      throw e;
    }
  }

  Future<void> updateAdminProfile(
      String uid,
      String firstname,
      String lastname,
      String age,
      String contact,
      String address,
      String images,
      String email) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'firstname': firstname,
        'lastname': lastname,
        'age': age,
        'contact': contact,
        'address': address,
        'images': images,
        'type': 'admin',
        'email': email,
      });
    } catch (e) {
      print('Error updating admin profile: $e');
      throw e;
    }
  }

  Future<void> createPet(
      String type,
      String pet_name,
      String age,
      String color,
      String arrivaldate,
      String size,
      String sex,
      String rescueLocation,
      String firstOwner,
      String healthIssues,
      String additionalDetails,
      String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('pet').add({
        'type': type,
        'pet_name': pet_name,
        'age': age,
        'color': color,
        'arrivaldate': arrivaldate,
        'size': size,
        'sex': sex,
        'rescue_location': rescueLocation,
        'first_owner': firstOwner,
        'health_issues': healthIssues,
        'additional_details': additionalDetails,
        'images': imageUrl,
        'status': 'Available'
      });
    } catch (e) {
      print('Error creating pet: $e');
      throw e;
    }
  }

  Future<void> createPetReport(
      String petName,
      String dateLost,
      String timeLost,
      String locationLost,
      String additionalInfo,
      String imageUrl,
      String userEmail) async {
    try {
      await FirebaseFirestore.instance.collection('pet_reports').add({
        'pet_name': petName,
        'date_lost': dateLost,
        'time_lost': timeLost, // Added time lost field
        'location_lost': locationLost,
        'additional_info': additionalInfo,
        'image': imageUrl,
        'user': userEmail,
        'status': 'In Progress', // Default status for new reports
      });
    } catch (e) {
      print('Error creating pet report: $e');
      throw e;
    }
  }

  // Function to update report status
  Future<void> updateReportStatus(String reportId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('pet_reports')
          .doc(reportId)
          .update({
        'status': status,
      });
    } catch (e) {
      print('Error updating report status: $e');
      throw e;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      throw e;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      throw e;
    }
  }
}
