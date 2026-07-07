import 'package:flutter/material.dart';
import 'feedback_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    final history = [
      {
        "vehicle": "Toyota Prius",
        "number": "CAB-4521",
        "service": "Full Vehicle Service",
        "workshop": "AutoNex Workshop",
        "date": "05 Jul 2026",
        "time": "10:00 AM",
        "status": "Completed",
      },
      {
        "vehicle": "Honda Fit",
        "number": "WP-CAB-7823",
        "service": "Engine Oil Replacement",
        "workshop": "AutoNex Workshop",
        "date": "28 Jun 2026",
        "time": "02:30 PM",
        "status": "Completed",
      },
      {
        "vehicle": "Suzuki Alto",
        "number": "CAA-1098",
        "service": "Brake Inspection",
        "workshop": "AutoNex Workshop",
        "date": "18 Jun 2026",
        "time": "09:00 AM",
        "status": "Cancelled",
      },
    ];


    return Scaffold(

      backgroundColor: const Color(0xFF0F0F1A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Service History",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: history.length,

        itemBuilder: (context,index){

          final item = history[index];

          final status = item["status"]!;

          final statusColor =
              status == "Completed"
              ? Colors.greenAccent
              : Colors.redAccent;


          return Container(

            margin: const EdgeInsets.only(bottom:20),

            padding: const EdgeInsets.all(18),


            decoration: BoxDecoration(

              color: Colors.white.withOpacity(.06),

              borderRadius: BorderRadius.circular(22),

              border: Border.all(
                color: Colors.white.withOpacity(.12),
              ),
            ),



            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,


              children: [


                Row(

                  children: [


                    const CircleAvatar(

                      radius:25,

                      backgroundColor:
                      Color(0xFF23314F),

                      child: Icon(
                        Icons.directions_car,
                        color: Colors.white,
                      ),
                    ),


                    const SizedBox(width:12),


                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,


                        children: [

                          Text(

                            item["vehicle"]!,

                            style: const TextStyle(

                              color: Colors.white,

                              fontSize:18,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),


                          Text(

                            item["number"]!,

                            style: const TextStyle(

                              color: Colors.white60,

                              fontSize:13,
                            ),
                          ),

                        ],
                      ),
                    ),



                    Container(

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal:12,
                        vertical:6,
                      ),


                      decoration: BoxDecoration(

                        color:
                        statusColor.withOpacity(.15),

                        borderRadius:
                        BorderRadius.circular(20),
                      ),


                      child: Text(

                        status,

                        style: TextStyle(

                          color:statusColor,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    )

                  ],
                ),



                const SizedBox(height:20),



                _infoRow(
                    Icons.build,
                    "Service",
                    item["service"]!
                ),


                const SizedBox(height:10),


                _infoRow(
                    Icons.store,
                    "Workshop",
                    item["workshop"]!
                ),


                const SizedBox(height:10),


                _infoRow(
                    Icons.calendar_today,
                    "Date",
                    item["date"]!
                ),


                const SizedBox(height:10),


                _infoRow(
                    Icons.access_time,
                    "Time",
                    item["time"]!
                ),




                if(status=="Completed")...[

                  const SizedBox(height:20),


                  SizedBox(

                    width:double.infinity,


                    child: OutlinedButton.icon(

                      onPressed:(){

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:(context)=>
                            const FeedbackPage(),
                          ),
                        );

                      },


                      icon:const Icon(
                        Icons.star_outline,
                      ),


                      label:const Text(
                        "Leave Feedback",
                      ),


                      style:OutlinedButton.styleFrom(

                        foregroundColor:
                        Colors.amber,

                        side:const BorderSide(
                          color:Colors.amber,
                        ),

                        shape:
                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                ]

              ],
            ),
          );
        },
      ),
    );
  }




  static Widget _infoRow(
      IconData icon,
      String title,
      String value,
      ){

    return Row(

      children: [

        Icon(
          icon,
          color:Colors.white60,
          size:18,
        ),


        const SizedBox(width:10),


        Text(

          "$title : ",

          style:const TextStyle(

            color:Colors.white70,

            fontWeight:
            FontWeight.w600,
          ),
        ),



        Expanded(

          child:Text(

            value,

            style:
            const TextStyle(
              color:Colors.white,
            ),
          ),
        )

      ],
    );
  }
}