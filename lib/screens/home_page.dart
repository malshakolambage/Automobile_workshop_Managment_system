import 'dart:ui';

import 'package:flutter/material.dart';

import 'booking_page.dart';
import 'history_page.dart';
import 'notification_page.dart';
import 'chat_workshop_page.dart';
import 'tracking_page.dart';
import 'feedback_page.dart';
import 'profile_page.dart';


import '../widgets/dashboard_card.dart';

class HomePage extends StatelessWidget {

  final String username;

  final bool hasActiveService = true;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF071120),
              Color(0xFF0B1E36),
              Color(0xFF102944),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              
              Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // TOP ROW
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,

                      children: [

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Welcome  $username ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Manage your vehicle services easily",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),



                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },

                          child: Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              color: Colors.white.withOpacity(0.08),

                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                            ),

                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                            ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    
                    // ACTIVE SERVICE CARD

                  GestureDetector(

                    onTap: hasActiveService
                        ? () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TrackingPage(),
                              ),
                            );

                          }
                        : null,


                    child: ClipRRect(

                      borderRadius:
                          BorderRadius.circular(24),


                      child: BackdropFilter(

                        filter: ImageFilter.blur(
                          sigmaX: 12,
                          sigmaY: 12,
                        ),


                        child: Container(

                          width: double.infinity,

                          padding:
                              const EdgeInsets.all(20),


                          decoration: BoxDecoration(

                            borderRadius:
                                BorderRadius.circular(24),


                            color:
                                Colors.white.withOpacity(0.08),


                            border: Border.all(

                              color:
                                  Colors.white.withOpacity(0.12),

                            ),
                          ),



                          child: Row(

                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,


                            children: [



                              Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment.start,


                                children: [


                                  const Text(

                                    "Active Service",

                                    style: TextStyle(

                                      color:
                                          Colors.white70,

                                      fontSize:14,
                                    ),
                                  ),



                                  const SizedBox(height:8),



                                  Text(

                                    hasActiveService
                                        ? "Toyota Prius - Engine Repair"
                                        : "No ongoing repairs",


                                    style: const TextStyle(

                                      color:
                                          Colors.white,

                                      fontSize:18,

                                      fontWeight:
                                          FontWeight.bold,

                                    ),
                                  ),



                                  const SizedBox(height:8),



                                  if(hasActiveService)

                                  const Text(

                                    "Repair in progress • Tap to track",

                                    style: TextStyle(

                                      color:
                                          Colors.greenAccent,

                                      fontSize:13,

                                    ),
                                  ),

                                ],
                              ),





                              Container(

                                padding:
                                    const EdgeInsets.all(14),


                                decoration: BoxDecoration(

                                  shape:
                                      BoxShape.circle,


                                  color:
                                      Colors.white.withOpacity(0.08),

                                ),



                                child: Icon(

                                  hasActiveService
                                      ? Icons.track_changes
                                      : Icons.car_repair,


                                  color:
                                      Colors.white,


                                  size:30,

                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),

              // SECTION 
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    "Quick Actions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // DASHBOARD 
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,

                    children: [

                      //  BOOK SERVICE

                      DashboardCard(
                        icon: Icons.calendar_month,
                        title: "Book Service",
                        type: CardType.services,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookingPage(),
                            ),
                          );
                        },
                      ),

                      // SERVICE HISTORY
                      DashboardCard(
                        icon: Icons.history,
                        title: "Service History",
                        type: CardType.analytics,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                        },
                      ),

                      // TRACK VEHICLE
                      DashboardCard(
                        icon: Icons.track_changes,
                        title: "Track Vehicle",
                        type: CardType.vehicles,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrackingPage(),
                            ),
                          );
                        },
                      ),

                      // CHAT WORKSHOP
                      DashboardCard(
                        icon: Icons.chat,
                        title: "Chat Workshop",
                        type: CardType.customers,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatPage(),
                            ),
                          );
                        },
                      ),

                      // NOTIFICATIONS
                      DashboardCard(
                        icon: Icons.notifications,
                        title: "Notifications",
                        type: CardType.services,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),

                      // FEEDBACK
                      DashboardCard(
                        icon: Icons.star_rate,
                        title: "Feedback",
                        type: CardType.analytics,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}