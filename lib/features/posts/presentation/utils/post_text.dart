/// Small helpers for showing the API's text nicely.
///
/// The API returns lowercase titles and bodies with hard line breaks, so they
/// are tidied up before being displayed.
extension PostText on String {
  /// This text with its first letter in upper case.
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// This text with line breaks replaced by spaces, for short previews.
  String get singleLine => replaceAll('\n', ' ');
}
