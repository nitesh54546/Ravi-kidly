import 'package:kidly/api/loginprovider.dart';
import 'package:kidly/api/studentprovider.dart';
import 'package:kidly/constant/searchprovider.dart';
import 'package:kidly/utils/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> provider = [
  ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
  ChangeNotifierProvider(create: (_) => SearchProvider()),
  ChangeNotifierProvider(create: (_) => LoginProvider()),
  ChangeNotifierProvider(create: (_) => StudentProvider())
];
