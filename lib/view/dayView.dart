import 'package:flutter/material.dart';

class dayView extends StatelessWidget {
  const dayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: const SingleDayCard()), //Creates one SingleDayCard
    );
  }
}

//The entirety of the dayView is one SingleDayCard
class SingleDayCard extends StatefulWidget {
  const SingleDayCard({super.key});
  @override
  State<StatefulWidget> createState() => SingleDayCardState();
}

//being stateful doesn't really do anything right now, but I'm pretty sure we need it later on
class SingleDayCardState extends State<SingleDayCard> {
  SingleDayCardState();
  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.hardEdge,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: InkWell(
          //Click/tap on any white part and it will go back to weekView
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.pop(context);
          },
          child: ListView(
            children: List.generate(24, (index) {
              //Generates 24 boxes, consisting of a Column that has a Divider on top of a Row with placeholder hour and a gray box next to one another
              return Column(
                children: [
                  const Divider(
                    //Creates divider
                    height: 10,
                    thickness: 2,
                    color: Colors.green, //Placeholder color
                  ),
                  Row(
                    children: [
                      Flexible(
                        //Like the weekView, works with Expanded to make the gray box fill up as much space as possible
                        flex: 0,
                        child: SizedBox(
                          width: 40,
                          child: Center(
                            child: Text("${index % 12}"), //Placeholder hour
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            //Makes a gray box that doesn't do anything right now
                            border: Border(
                                /*top: BorderSide(color: Color(0xFFDFDFDF)),
                              left: BorderSide(color: Color(0xFFDFDFDF)),
                              right: BorderSide(color: Color(0xFF7F7F7F)),
                              bottom: BorderSide(color: Color(0xFF7F7F7F)),*/
                                ),
                            color: Color(0xFFBFBFBF),
                          ),
                          child: SizedBox(
                            //Also not idea how I'm going to connect the backend with this, but better to have something than nothing
                            height: 40,
                            child: InkWell(
                              //More splashy click but it doesn't do anything for now
                              splashColor: Colors.red.withAlpha(30),
                              onTap: () {},
                              child: const Center(
                                child: Column(
                                  children: [
                                    Text("千里之外"), //Placeholder
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ));
  }
}
