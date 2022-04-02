/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
class CallRawResponse {
  final bool isSuccessful;
  final List<int> receivedBytes;
  const CallRawResponse(this.isSuccessful, this.receivedBytes);

  factory CallRawResponse.failed() {
    return const CallRawResponse(false, []);
  }

  factory CallRawResponse.success(List<int> data) {
    return CallRawResponse(true, data);
  }
}