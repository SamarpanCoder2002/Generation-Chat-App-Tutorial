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

enum ConnectionStateName{
  Connect,
  Pending,
  Accept,
  Connected,
}

enum ConnectionStateType{
  ButtonNameWidget,
  ButtonBorderColor,
  ButtonOnlyName,
}

enum OtherConnectionStatus{
  Request_Pending,
  Invitation_Came,
  Invitation_Accepted,
  Request_Accepted,
}

enum ChatMessageTypes{
  None,
  Text,
  Image,
  Video,
  Document,
  Audio,
  Location,
}

enum ImageProviderCategory{
  FileImage,
  ExactAssetImage,
  NetworkImage,
}