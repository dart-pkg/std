import 'package:test/test.dart';
import 'package:std/std.dart';

const int megaByte = 1024 * 1024;

void main() {
  group('SysInfo', () {
    test('(1)', () {
      print('Kernel architecture     : ${SysInfo.kernelArchitecture}');
      print('Kernel bitness          : ${SysInfo.kernelBitness}');
      print('Kernel name             : ${SysInfo.kernelName}');
      print('Kernel version          : ${SysInfo.kernelVersion}');
      print('Operating system name   : ${SysInfo.operatingSystemName}');
      print('Operating system version: ${SysInfo.operatingSystemVersion}');
      print('User directory          : ${SysInfo.userDirectory}');
      print('User id                 : ${SysInfo.userId}');
      print('User name               : ${SysInfo.userName}');
      print('User space bitness      : ${SysInfo.userSpaceBitness}');
      print(
        'Total physical memory   : ${SysInfo.getTotalPhysicalMemory() ~/ megaByte} MB',
      );
      print(
        'Free physical memory    : ${SysInfo.getFreePhysicalMemory() ~/ megaByte} MB',
      );
      print(
        'Total virtual memory    : ${SysInfo.getTotalVirtualMemory() ~/ megaByte} MB',
      );
      print(
        'Free virtual memory     : ${SysInfo.getFreeVirtualMemory() ~/ megaByte} MB',
      );
      print(
        'Virtual memory size     : ${SysInfo.getVirtualMemorySize() ~/ megaByte} MB',
      );
    });
  });
}
