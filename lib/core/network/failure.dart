class Failure {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = "Erreur de connexion réseau. Veuillez vérifier votre connexion."]) 
      : super(message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = "Le serveur ne répond pas. Veuillez réessayer plus tard.", int? statusCode]) 
      : super(message, statusCode: statusCode);
}

class AuthFailure extends Failure {
  AuthFailure([String message = "Échec de l'authentification."]) : super(message);
}
