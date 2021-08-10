enum EmailSignUpResults{
  SignUpCompleted,
  EmailAlreadyPresent,
  SignUpNotCompleted,
}

enum EmailSignInResults{
  SignInCompleted,
  EmailNotVerified,
  EmailOrPasswordInvalid,
  UnexpectedError,
}

enum GoogleSignInResults{
  SignInCompleted,
  SignInNotCompleted,
  UnexpectedError,
  AlreadySignedIn,
}

enum FBSignInResults{
  SignInCompleted,
  SignInNotCompleted,
  AlreadySignedIn,
  UnExpectedError,
}

enum StatusMediaTypes{
  TextActivity,
  ImageActivity,
}