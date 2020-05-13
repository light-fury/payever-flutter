import 'package:payever/commons/network/rest_ds.dart';

import '../view_models/view_models.dart';
import '../models/models.dart';
import '../network/pos_api.dart';

class PosStateModel extends PosStateCommonsModel {
  GlobalStateModel globalStateModel;
  PosApi posApi;

  PosStateModel(this.globalStateModel, this.posApi) : super(globalStateModel);

  Future<void> loadPosProductsList(Terminal terminal) async {

    try {
//      var inventories = await getAllInventory();
//      List<InventoryModel> inventoryModelList = List<InventoryModel>();
//
//      inventories.forEach((inv) {
//        InventoryModel _currentInv = InventoryModel.toMap(inv);
//        inventoryModelList.add(_currentInv);
//      });
//
//      addProductListStock(inventoryModelList);

      if (terminal == null) {
        List<Terminal> _terminals = List();
        List<ChannelSet> _chSets = List();
        var terminals = await getTerminalsList();
        terminals.forEach((terminal) {
          _terminals.add(Terminal.toMap(terminal));
        });
        var channelSets = await getChannel();
        channelSets.forEach((channelSet) {
          _chSets.add(ChannelSet.toMap(channelSet));
        });

        currentTerminal = _terminals.firstWhere((term) => term.active);

        var checkout = await getCheckout(currentTerminal.channelSet);
        currentCheckout = Checkout.toMap(checkout);
//        smsEnabled = !currentCheckout.sections.firstWhere((test)=> test.code=="send_to_device").enabled;

//        haveProducts = true;
//        dataFetched = false;
//        loadMore = false;

//        updateFetchValues(true, false);

        return true;
      } else {
        var checkout = await getCheckout(terminal.channelSet);
        currentCheckout = Checkout.toMap(checkout);

        currentTerminal = terminal;

//        haveProducts = true;
//        dataFetched = false;
//        loadMore = false;
//        updateFetchValues(true, false);

        return true;
      }
    } catch (e) {
      print("Error: $e");

      return false;
    }
  }

  Future<dynamic> getAllInventory() async {
    return posApi.getAllInventory(businessId, accessToken);
  }

  Future<dynamic> getInventory(String sku) async {
    print("inventorySKU: $sku");

    print("theglobalStateModel: $globalStateModel");
    print("businessId: $businessId");
    return posApi.getInventory(businessId, accessToken, sku, null);
  }

  Future<dynamic> getTerminalsList() async {
    return posApi.getTerminal(businessId, accessToken, null);
  }

  Future<dynamic> getChannel() async {
    return posApi.getChannelSet(businessId, accessToken, null);
  }

  Future<dynamic> getCheckout(String terminalChannelSet) async {
    return posApi.getCheckout(terminalChannelSet, accessToken);
  }
}
