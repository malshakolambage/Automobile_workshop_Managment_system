import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:customer_app/services/api_service.dart';

import 'booking_page.dart';
import 'history_page.dart';
import 'notification_page.dart';
import 'chat_workshop_page.dart';
import 'tracking_page.dart';
import 'feedback_page.dart';
import 'profile_page.dart';


import '../widgets/dashboard_card.dart';

class HomePage extends StatefulWidget {

  final String username;

  const HomePage({
    super.key,
    required this.username,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? activeAppointment;
  bool _loading = true;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    // Start with whatever was passed in (e.g. straight after login), then
    // refresh from the locally cached profile in case it was edited since.
    _displayName = widget.username;
    _loadUserName();
    _loadActiveService();
  }

  Future<void> _loadUserName() async {
    final name = await ApiService.getUserName();
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      setState(() => _displayName = name);
    }
  }

  Future<void> _loadActiveService() async {
    final appointments = await ApiService.getAppointments();
    final active = appointments.cast<Map<String, dynamic>>().firstWhere(
          (a) => a["status"] == "Approved" && a["progress"] != "Ready for Pickup",
          orElse: () => {},
        );

    if (!mounted) return;
    setState(() {
      activeAppointment = active.isEmpty ? null : active;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final hasActiveService = activeAppointment != null;

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
                              "Welcome  $_displayName ",
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
                            ).then((_) => _loadUserName());
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
                            ).then((_) => _loadActiveService());

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

                                    _loading
                                        ? "Checking..."
                                        : hasActiveService
                                            ? "${activeAppointment!['model'] ?? 'Vehicle'} - ${activeAppointment!['service_type'] ?? ''}"
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

                                  Text(

                                    "${activeAppointment!['progress'] ?? 'In progress'} • Tap to track",

                                    style: const TextStyle(

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
                          ).then((_) => _loadActiveService());
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