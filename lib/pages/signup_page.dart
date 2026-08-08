import 'package:Wavelet/pages/initalpair/inital-pair_page.dart';
import 'package:Wavelet/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Wavelet/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.toggleTheme});

  @override
  State<SignupPage> createState() => _SignupPageState();
  final VoidCallback toggleTheme; // add this
}

class _SignupPageState extends State<SignupPage> {

//text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserService _userService = UserService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(
          _nameController.text.trim(),
        );

        await _userService.createUserProfile(
          uid: user.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InitialPair(
            toggleTheme: () {},
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _getAuthErrorMessage(e.code),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            // 'Something went wrong while creating your account.',
               'Signup error: $e',
          ),
        ),
      );
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      // Login
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'user-not-found':
        return 'No account exists with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'invalid-credential':
        return 'Incorrect email or password.';

      // Signup
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Your password is too weak.';

      // General
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }

  //test function
// Future<void> _testFirestore() async {
//   try {
//     print('Testing Firestore...');

//     final user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       print('No authenticated user!');
//       return;
//     }

//     print('Current UID: ${user.uid}');

//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .set({
//       'name': 'Firestore Test',
//       'email': user.email,
//       'createdAt': FieldValue.serverTimestamp(),
//     });

//     print('Firestore write successful!');
//   } catch (e) {
//     print('FIRESTORE WRITE ERROR: $e');
//   }
// }


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaveletColors.background(context),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //wavelet logo
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(146, 62, 146, 41),
              child: Container(
                child: Image.asset(
                  'assets/images/wavelet_logo.png',
                  width: 138,
                  height: 48,
                ),
              ),
            ),
          ),
            //SizedBox(height: 81),

            //text header
          Container(
            child: Padding(
              padding: const EdgeInsets.only(left:35),
              child: Text(
                "Create an account",
                style: TextStyle(
                  color: WaveletColors.textPrimary(context),
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                ),
            )
            ),

            // //test button
            // //delete this later
            // ElevatedButton(
            //     onPressed: _testFirestore,
            //     child: const Text('Test Firestore'),
            //   ),
        
        //text header
            Container(
              width: 308,
              height: 24,
              child: Padding(
              padding: const EdgeInsets.only(left:35),
                child: Text(
                  "Join wavelet to manage your speakers",
                  style: TextStyle(
                    color: WaveletColors.textSecondary(context),
                    fontFamily: 'Nunito',
                    fontSize: 16,
                  fontWeight: FontWeight.w800,
                  ),
                  ),
              ),
            ),


          //username
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(44, 48, 44, 16),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: "Your name",
                    filled: true,
                    fillColor: WaveletColors.surfaceVariant(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none, // removes the outline border
                    ),
                  
                  hintStyle: TextStyle(
                    color: WaveletColors.textDisabled(context),
                    // style: Theme.of(context).textTheme.displayLarge
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  )
                  ),
                ),
              ),
            ),
        
        //email
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(44, 0, 44, 0.8),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email address",
                    filled: true,
                    fillColor: WaveletColors.surfaceVariant(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none, // removes the outline border
                    ),
                  
                  hintStyle: TextStyle(
                    color: WaveletColors.textDisabled(context),
                    // style: Theme.of(context).textTheme.displayLarge
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  )
                  ),
                ),
              ),
            ),
        
        //password
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(44, 16, 44, 0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Password",
                    filled: true,
                    fillColor: WaveletColors.surfaceVariant(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none, // removes the outline border
                    ),
                  
                  hintStyle: TextStyle(
                    color: WaveletColors.textDisabled(context),
                    // style: Theme.of(context).textTheme.displayLarge
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500
                  )
                  ),
                ),
              ),
            ),
        
        //forgot password
            Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(44, 14, 44, 20),
                child: Text(
                  "By creating an account you agree to the Terms of Service and Privacy Policy.",
                  style: TextStyle(
                    color: WaveletColors.secondaryButtonText(context),
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
        
          //signup button
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WaveletColors.primaryButton(context),
                    foregroundColor: WaveletColors.primaryButtonText(context),
                    minimumSize: Size(294, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text("Create account"),
                ),
              ),
            ),
        
        //line divider
          Padding(
            padding: const EdgeInsets.only(top: 31.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 113,
                  child: Divider(color: WaveletColors.divider(context)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "or continue with",
                    style: TextStyle(
                      color: WaveletColors.textDisabled(context),
                      fontFamily: 'Inter',
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  width: 113,
                  child: Divider(color: WaveletColors.divider(context)),
                ),
              ],
            ),
          ),
        
        //other signin options
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //google
                    ElevatedButton.icon(
                    onPressed: () {}, //change later<<
            
                    icon: Image.asset('assets/images/google.png', width: 24, height: 24,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WaveletColors.secondaryButton(context),
                      foregroundColor: WaveletColors.secondaryButtonText(context),
                      minimumSize: Size(165, 53.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
            
                    ),
                    label: Text("Google"),
                  ),
                  SizedBox(width: 12,),
                  //apple
                    ElevatedButton.icon(
                    onPressed: () {}, //change later<<
            
                    icon: Image.asset('assets/images/apple.png', width: 24, height: 24,),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WaveletColors.secondaryButton(context),
                      foregroundColor: WaveletColors.secondaryButtonText(context),
                      minimumSize: Size(165, 53.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
            
                    ),
                    label: Text("Apple"),
                  ),
            
            
              ],
            ),
          ),
        
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height:136.4),
          
              Text(
              "Already have an account? ",
              style: TextStyle(
                color: WaveletColors.textSecondary(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
              )
          ),
          
          SizedBox(width: 23.66,),
          
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(toggleTheme: () {
                
              },) ));
            },
            child: Text(
                "Log In",
                style: TextStyle(
                  color: WaveletColors.primaryButton(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                )
            ),
          )
          
          
            ],
          ),
        
        
          ], //end of column
        ),
      )

    );
  }
}