
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget{

  const HomePage({Key? key}): super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{

  final _linhas = <String>[];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usando GPS'),
      ),
      body: _criarBody() ,
    );
  }

  Widget _criarBody() => Padding(
      padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        ElevatedButton(
            onPressed: _obterUltimaLocalizacaoConhecida,
            child: const Text('Obter ultima localização conhecida')
        ),
        const Divider(),
        Expanded(
            child: ListView.builder(
              shrinkWrap: true,
                itemCount: _linhas.length,
                itemBuilder:(_, index) => Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(_linhas[index]),
                ),
            ),
        ),
      ],
    ),
  );

  void _obterUltimaLocalizacaoConhecida() async{
    bool permissoesPermitidas = await _permissoesPermitidas();
    if (!permissoesPermitidas){
      return;
    }
    Position? position = await Geolocator.getLastKnownPosition();
    setState(() {
      if( position == null){
        _linhas.add('Nenhuma localização encontrada!');
      }else{
        _linhas.add('Latitude: ${position.latitude}  |'
            '  Logetude: ${position.longitude}');
      }
    });
  }

  Future<bool> _permissoesPermitidas() async{
    LocationPermission permissao = await Geolocator.checkPermission();

    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied){
        _mostrarMensagem(
          'Não será possível usar o recurso por falta de permissão'
        );
        return false;
      }
    }
    if (permissao == LocationPermission.deniedForever){
      await _mostrarDialogMensagem(
        'Para utilizar esse recurso, você deverá acessar as configurações'
            ' do app e permitir a utilização do serviço de localização'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mensagem),
    ));
  }

  Future<void> _mostrarDialogMensagem(String mensagem) async {
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Atenção'),
          content: Text(mensagem),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK')
            )
          ],
        )
    );
  }

}