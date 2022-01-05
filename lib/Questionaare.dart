// ignore: file_names
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Questions extends StatefulWidget {
  @override
  _QuestionsState createState() => _QuestionsState();
}

class _QuestionsState extends State<Questions> {

  Map<String,String> answers = {};

  bool _flag = false;

  List<String> options = ['a.    Never','b.    Rarely','c.    Once In a While','d.    Fairly Often','e.    Always'];

  int noOfCompletedQuestions = 0;

  int noOfTotalQuestions = 0;

  bool questionarrieCompleted = false;

  int user_id = 1;


  // Create an instance variable.
  late final Future? myFuture;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    user_id= user!.uid as int;
    // Assign that variable your Future.
    myFuture = getData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If we got an error
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '${snapshot.error} occured',
                  style: TextStyle(fontSize: 18),
                ),
              );
              // if we got our data
            } else if (snapshot.hasData) {
              // Extracting data from snapshot object
              Map<String,dynamic> valueMap = snapshot.data as Map<String,dynamic>;
              List<dynamic> data = valueMap["data"];
              noOfTotalQuestions = data.length;
              print("Total Number of Questions :"+noOfTotalQuestions.toString());
              //final data = snapshot.data as String;
              return SafeArea(child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: PreferredSize(
                      preferredSize: Size.fromHeight(60.0), // here the desired height
                      child:AppBar(
                      centerTitle: true,
                      title: Padding(padding: EdgeInsets.only(top: 30),child:RichText(
                        text: TextSpan(
                            text: '$noOfCompletedQuestions',
                            style: GoogleFonts.roboto(
                              textStyle: Theme.of(context).textTheme.headline4,
                              fontSize: 32,
                              color: Color(0xff24224D),
                              fontWeight: FontWeight.w700,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "/$noOfTotalQuestions",
                                style: GoogleFonts.roboto(
                                  textStyle: Theme.of(context).textTheme.headline4,
                                  fontSize: 24,
                                  color: Colors.grey,
                                ),
                              )]),
                      )),
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      leading: Padding(padding: EdgeInsets.only(left: 40,top: 30),child:Icon(Icons.arrow_back_ios)),
                        toolbarHeight: 190.0,
                  )),
                  body: Center(
                  child:Column(
                  children: [
                    Container(
                        alignment: Alignment.topCenter,
                        margin: EdgeInsets.all(20),
                        child: LinearProgressIndicator(
                          value: ((noOfCompletedQuestions - 0) / (noOfTotalQuestions - 0)+0),
                          valueColor: new AlwaysStoppedAnimation<Color>(Color(0xff24224D)),
                        )
                    ),
                    Padding(padding: EdgeInsets.all(30),child: RichText(
                      text: TextSpan(
                          text: valueMap["data"][noOfCompletedQuestions]["sub_heading"]??"" + " ",
                          style: GoogleFonts.roboto(
                            textStyle: Theme.of(context).textTheme.headline4,
                            fontSize: 36,
                            color: Color(0xff24224D),
                            fontWeight: FontWeight.w700,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: valueMap["data"][noOfCompletedQuestions]["question"],
                              style: GoogleFonts.roboto(
                                textStyle: Theme.of(context).textTheme.headline4,
                                fontSize: 36,
                                color: Color(0xff24224D),

                              ),
                            )]),
                    ),),
                    Padding(padding: EdgeInsets.only(left: 30,right: 30),child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: 5,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 20,),
                      itemBuilder: (BuildContext context, int index) {
                        return OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed))
                                  return Color(0xff9FFAE8);
                                if (states.contains(MaterialState.selected))
                                  return Color(0xff9FFAE8);
                                return Color(0xffDEDEE4); // Use the component's default.
                              },
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(child:Text(options[index],style: GoogleFonts.roboto(
                                textStyle: Theme.of(context).textTheme.headline4,
                                fontSize: 20,
                                color: Color(0xff24224D),
                                fontWeight: FontWeight.w300
                            ),) ,padding: EdgeInsets.only(left: 20,top: 20,bottom: 20),),
                          ),
                          onPressed: () {
                            //Add Answer to Map
                            postTheAnswers(user_id,valueMap["data"][noOfCompletedQuestions]["id"],index);
                            //Update the Value of Stepper
                            //And SetState
                          },
                        );
                      },
                    ),)
                  ],
                )))
              );
            }
          }
          // Displaying LoadingSpinner to indicate waiting state
          return Center(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              )
            ),
          );
        },

        // Future that needs to be resolved
        // inorder to display something on the Canvas
        future: myFuture,
      );
  }

  Future<Map<String,dynamic>?> getData() async {
    Map<String,dynamic> valueMap = {};
    var request = http.Request('GET', Uri.parse('http://www.markitiers.in/codee/public/api/get/question'));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String result = await response.stream.bytesToString();
      valueMap = jsonDecode(result);
      return valueMap;
    }
    else {
    print(response.reasonPhrase);
    }
  }


  Future<bool?> postTheAnswers(int userid,int question_id,int answer) async {
    //await Future.delayed(Duration(seconds: 1));
    if(noOfCompletedQuestions<noOfTotalQuestions-1){
      noOfCompletedQuestions++;
    }
    else{
      questionarrieCompleted = true;
      setState(() {});

    }
    print(answers);
    setState(() {});

    var request = http.Request('POST', Uri.parse('http://www.markitiers.in/codee/public/api/auth/user/ans?user_id=$userid&question_id=$question_id&answer=$answer&created_at'));
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.reasonPhrase);
    }

  }
}
