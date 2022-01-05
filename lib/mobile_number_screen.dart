import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'Questionaare.dart';

class MobileNumberScreen extends StatefulWidget {
  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'IN';
  PhoneNumber number = PhoneNumber(isoCode: 'IN');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;

  bool isLoading = false;

  String phoneNumberString = "";

  bool isAValidPhoneNumber = false;

  bool loadOtpPage = false;

  bool isAValidOTP = false;

  bool showPhoneNumberError = false;

  String otpString = "";

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        resizeToAvoidBottomInset : false,
        backgroundColor: Colors.white,
        body: !loadOtpPage?Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40,),
            Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: 2,
              color: Colors.grey,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/10,
                    color: Color(0xff24224D),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/8,),
            Padding(padding: EdgeInsets.only(right:80,top: 30),child: Text(
              'My number is',
              style: GoogleFonts.roboto(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 40,
                color: Color(0xff24224D),
                fontWeight: FontWeight.w700,
              ),
            )),
            SizedBox(height: MediaQuery.of(context).size.height/8,),
            Padding(padding: EdgeInsets.all(30),child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: InternationalPhoneNumberInput(

                      textStyle:GoogleFonts.roboto(
                      textStyle: Theme.of(context).textTheme.button,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    spaceBetweenSelectorAndTextField: 0,

                    inputDecoration: InputDecoration(
                    border: InputBorder.none,
                    errorText: showPhoneNumberError?"Please Enter a Valid Phone Number":null,
                    hintText: 'Phone Number',
                    hintStyle: GoogleFonts.roboto(
                      textStyle: Theme.of(context).textTheme.button,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onInputChanged: (PhoneNumber number) {
                    phoneNumberString = number.phoneNumber.toString();
                    print(number.phoneNumber.toString());
                  },
                  onInputValidated: (bool value) {
                    print(value);
                    isAValidPhoneNumber = value;
                    showPhoneNumberError=!isAValidPhoneNumber;
                    setState(() {

                    });

                  },
                  selectorConfig: SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                    leadingPadding: 0.0,
                  ),
                  ignoreBlank: false,
                  autoValidateMode: AutovalidateMode.disabled,
                  selectorTextStyle: TextStyle(color: Colors.black),
                  initialValue: number,
                  textFieldController: controller,
                  formatInput: false,
                  autoFocus: true,
                  keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
                  inputBorder: null,
                  onSaved: (PhoneNumber number) {
                    print('On Saved: $number');
                  },
                ),
              ),
            ),),
            Container(
              width: MediaQuery.of(context).size.width*0.85,
              child: OutlinedButton(
                onPressed: () async {
                  if(isAValidPhoneNumber){
                    await phoneSignIn( phoneNumber: phoneNumberString);
                  }
                  else{
                    showPhoneNumberError=true;
                  }
                  },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                ),
                child:Padding(padding: EdgeInsets.all(25),child:Text("Continue",style: GoogleFonts.roboto(
                  textStyle: Theme.of(context).textTheme.button,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),)),
              ),
            )
          ],
        ):Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40,),
            Container(
              width: MediaQuery.of(context).size.width*0.8,
              height: 2,
              color: Colors.grey,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width/10,
                    color: Color(0xff24224D),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width/2,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height/8,),
            Padding(padding: EdgeInsets.only(left: 30,top: 30),child: Text(
              'Verification Code is',
              style: GoogleFonts.roboto(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 48,
                color: Color(0xff24224D),
                fontWeight: FontWeight.w700,
              ),
            )),
            Padding(padding: EdgeInsets.only(left: 30),child: Text(
              'Enter the code we\'ve sent to $phoneNumberString',
              style: GoogleFonts.roboto(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 20,
                color: Color(0xff24224D),
                fontWeight: FontWeight.w300,
              ),
            )),
            Padding(padding: EdgeInsets.only(left: 30,right: 30,top: 30,bottom: 10),child: OtpTextField(
              numberOfFields: 6,
              borderColor: Color(0xFF512DA8),
              //set to true to show as box or false to show as dash
              showFieldAsBox: true,
              borderRadius: BorderRadius.circular(10),
              fieldWidth: 50,
              textStyle: GoogleFonts.roboto(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 22,
                color: Color(0xff24224D),
                fontWeight: FontWeight.w700,
              ),
              //runs when a code is typed in
              onCodeChanged: (String code) {
                //handle validation or checks here
                if(code.length==6){
                  if(otpString == code){
                    isAValidOTP = true;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Questions()),
                    );
                  }

                }
              },
              //runs when every textfield is filled
              onSubmit: (String verificationCode){
                if(otpString == verificationCode){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Questions()),
                  );
                }
              }, // end onSubmit
            ),),
            Visibility(visible: isAValidOTP,child: Text(
              isAValidOTP?'Wrong OTP':'Correct OTP',
              style: GoogleFonts.roboto(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 20,
                color: isAValidOTP?Colors.redAccent:Colors.green,
                fontWeight: FontWeight.w700,
              ),
            ),),
            SizedBox(height: 40,),
            TextButton(onPressed: () async {
                await phoneSignIn(phoneNumber: phoneNumberString);
              }, child: Text(
              'Code Not Recieved ?',
              style: GoogleFonts.roboto(
                decoration: TextDecoration.underline,
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 20,
                color: Color(0xff24224D),
                fontWeight: FontWeight.w300,
              ),
            ),)
          ],
        ),
    ));
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: _onVerificationCompleted,
        verificationFailed: _onVerificationFailed,
        codeSent: _onCodeSent,
        codeAutoRetrievalTimeout: _onCodeTimeout);
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    print("verification completed ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      otpString = authCredential.smsCode!;
    });
    if (authCredential.smsCode != null) {
      try{
        UserCredential credential =
        await user!.linkWithCredential(authCredential);
      }on FirebaseAuthException catch(e){
        if(e.code == 'provider-already-linked'){
          await _auth.signInWithCredential(authCredential);
        }
      }
      setState(() {
        isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Questions()),
      );
    }
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (exception.code == 'invalid-phone-number') {
      showMessage("The phone number entered is invalid!");
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    print(forceResendingToken);
    print("code sent");
    loadOtpPage = true;
    setState(() {});
  }

  _onCodeTimeout(String timeout) {
    return null;
  }

  void showMessage(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () async {
                  Navigator.of(builderContext).pop();
                },
              )
            ],
          );
        }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

}
