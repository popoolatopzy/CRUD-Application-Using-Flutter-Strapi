import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final HttpLink httpLink = HttpLink("http://localhost:1337/graphql");

final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(),
  ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const RegisterScreen(),
          '/users': (context) => const UsersScreen(),
          '/edit': (context) => const EditProfileScreen(),
        },
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with form submission
      String name = _nameController.text;
      String email = _emailController.text;
      String username = _usernameController.text;

      // Perform desired operations with the form data
      print('Name: $name');
      print('Email: $email');
      print('Username: $username');

      // Mutation variables
      final Map<String, dynamic> variables = {
        'name': name,
        'username': username,
        'email': email,
      };

      MutationOptions options = MutationOptions(
        document: gql("""
          mutation CreateApp(\$name: String!, \$username: String!, \$email: String!) {
            createApp(data: { name: \$name, username: \$username, email: \$email }) {
              data {
                attributes {
                  name
                  username
                  email
                }
              }
            }
          }
          """),
        variables: variables,
        onCompleted: (dynamic resultData) {
          // Mutation was completed successfully
          print('Mutation Result: $resultData');
          // Redirect to the profile screen after successful registration
          Navigator.pushNamed(context, '/users');
        },
      );

      client.value.mutate(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Add additional email validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql("""
            query {
              apps {
                data {
                  id
                  attributes {
                    name
                    username
                    email
                  }
                }
              }
            }
            """),
        ),
        builder: (result1, {fetchMore, refetch}) {
          if (result1.hasException) {
            // Query encountered an error
            print('Query Error: ${result1.exception.toString()}');
            return const Center(
              child: Text('An error occurred'),
            );
          }

          if (result1.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final posts = result1.data!['apps']['data'];

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final name = post['attributes']['name'];

              return ListTile(
                leading: Icon(Icons.person),
                title: Text(post['attributes']['name']),
                subtitle: Text(post['attributes']['email']),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/edit',
                    arguments: {
                      "userID": post['id'],
                      "name": post['attributes']['name'],
                      "email": post['attributes']['email'],
                      "username": post['attributes']['username'],
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _useridController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _useridController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String username = _usernameController.text;
      String userid = _useridController.text;

      final Map<String, dynamic> variables = {
        'appId': userid,
        'name': name,
        'username': username,
        'email': email,
      };

      MutationOptions options = MutationOptions(
        document: gql("""
          mutation UpdateApp(\$appId: ID!, \$name: String!, \$username: String!, \$email: String!) {
            updateApp(id: \$appId, data: { name: \$name, username: \$username, email: \$email }) {
              data {
                attributes {
                  name
                  username
                  email
                }
              }
            }
          }
          """),
        variables: variables,
        onCompleted: (dynamic resultData) {
          // Mutation was completed successfully
          print('Mutation Result: $resultData');
          // Redirect to the profile screen after successful update
          Navigator.pushReplacementNamed(context, '/users');
        },
      );

      client.value.mutate(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String userID = args?['userID'] as String? ?? '';
    final String name = args?['name'] as String? ?? '';
    final String email = args?['email'] as String? ?? '';
    final String username = args?['username'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController..text = name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController..text = email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Add additional email validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _usernameController..text = username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _useridController..text = userID,
                decoration: const InputDecoration(
                  labelText: 'UserID',
                ),
                readOnly: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your ID';
                  }
                  // Add additional email validation if needed
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Perform delete operation here
                  final Map<String, dynamic> variables = {
                    'id': userID,
                  };

                  MutationOptions options = MutationOptions(
                    document: gql('''
                      mutation DeleteApp(\$id: ID!) {
                        deleteApp(id: \$id) {
                          data {
                            attributes {
                              name
                            }
                          }
                        }
                      }
                    '''),
                    variables: variables,
                    onCompleted: (dynamic resultData) {
                      // Mutation was completed successfully
                      print('Mutation Result: $resultData');
                      // Redirect to the profile screen after successful deletion
                      Navigator.pushReplacementNamed(context, '/users');
                    },
                  );

                  client.value.mutate(options);
                },
                child: const Text('Delete User'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
