/*
 ** Created by Mustafa Kemal ÖZDEMİR on 2.04.2022 **
*/
class MachineMessage<T> {
  final T flag;
  final dynamic obj;

  const MachineMessage(this.flag, this.obj);
}
