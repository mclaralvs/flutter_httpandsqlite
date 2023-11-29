class User {
  final int id;
  final String name;
  final String pwd;

  User({
    required this.id, 
    required this.name, 
    required this.pwd
    });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pwd': pwd,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      pwd: map['pwd'],
    );
  }
}
