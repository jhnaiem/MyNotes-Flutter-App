import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/app_router.gr.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/cubit/auth_cubit.dart';
import '../../services/crud/models/database_note.dart';
import '../../utilities/dialogs/logout_dialog.dart';

@RoutePage()
class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes'),
          actions: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ElevatedButton.icon(
                onPressed: () {
                  router.push(CreateUpdateNoteRoute());
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add',
                  style: TextStyle(color: Colors.amberAccent),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthCubit>().logOut();
                    }
                    break;
                  default:
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                      value: MenuAction.logout, child: Text('Logout'))
                ];
              },
            )
          ],
        ),
        body: FutureBuilder(
          future: _notesService.getOrCreateUser(email: userEmail),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: allNotes,
                            onDelete: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            },
                            onTap: (DatabaseNote note) {
                              router.push(
                                  CreateUpdateNoteRoute(databaseNote: note));
                            },
                          );
                        } else {
                          return const Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        }
                      default:
                        return const Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        );
                    }
                  },
                );
              default:
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
            }
          },
        ));
  }
}
