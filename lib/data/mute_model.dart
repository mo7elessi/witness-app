import 'package:nice_shot/presentation/features/editor/pages/trimmer_page.dart';

class MuteModel {
  int muteStart;
  int muteEnd;
  MuteModel({required this.muteStart, required this.muteEnd});
  static String notRelatedSection = "";

  static void verifyMuteModel({
    required MuteModel model,
    required List<MuteModel> muteModelList,
  }) {
    if (muteModelList.isEmpty) {
      muteModelList.add(model);
    } else {
      for (var element in muteModelList) {
        _processing(TrimmerPage.model!, element, muteModelList);
      }
      if (notRelatedSection == "true") {
        muteModelList.add(model);
        notRelatedSection = "";
      }
      _filtering(muteModelList);
    }
    muteModelList.forEach((element) {
      print("start:${element.muteStart}???end:${element.muteEnd}");
    });
  }

  static void _processing(MuteModel muteModelToAdd,
      MuteModel muteModelToCompareTo, List<MuteModel> list) {
    if (muteModelToCompareTo.muteStart <= muteModelToAdd.muteStart &&
        muteModelToCompareTo.muteEnd >= muteModelToAdd.muteEnd) {
      TrimmerPage.model = muteModelToCompareTo;
    }
    if ((muteModelToCompareTo.muteStart > muteModelToAdd.muteStart) &&
        (muteModelToCompareTo.muteEnd >= muteModelToAdd.muteEnd) &&
        muteModelToAdd.muteEnd > muteModelToCompareTo.muteStart) {
      muteModelToCompareTo.muteStart = muteModelToAdd.muteStart;
      TrimmerPage.model = muteModelToCompareTo;
    }
    if (muteModelToCompareTo.muteStart <= muteModelToAdd.muteStart &&
        muteModelToAdd.muteStart < muteModelToCompareTo.muteEnd &&
        muteModelToAdd.muteEnd > muteModelToCompareTo.muteEnd) {
      muteModelToCompareTo.muteEnd = muteModelToAdd.muteEnd;
      TrimmerPage.model = muteModelToCompareTo;
    }
    if (muteModelToCompareTo.muteStart > muteModelToAdd.muteStart &&
        muteModelToCompareTo.muteEnd < muteModelToAdd.muteEnd) {
      muteModelToCompareTo.muteStart = muteModelToAdd.muteStart;
      muteModelToCompareTo.muteEnd = muteModelToAdd.muteEnd;
      TrimmerPage.model = muteModelToCompareTo;
    }
    if (muteModelToCompareTo.muteStart == muteModelToAdd.muteEnd) {
      muteModelToCompareTo.muteStart = muteModelToAdd.muteStart;
      TrimmerPage.model = muteModelToCompareTo;
    }
    if (muteModelToCompareTo.muteEnd == muteModelToAdd.muteStart) {
      muteModelToCompareTo.muteEnd = muteModelToAdd.muteEnd;
      TrimmerPage.model = muteModelToCompareTo;
    }
    if (muteModelToAdd.muteStart > muteModelToCompareTo.muteEnd ||
        muteModelToAdd.muteEnd < muteModelToCompareTo.muteStart) {
      notRelatedSection = "true";
    }
  }

  static void _filtering(List<MuteModel> list) {
    int minimumStart = 0;
    int maximumEnd = 0;
    MuteModel? toReAdd;
    List<MuteModel> sameStartFilter = [];
    if (list.isNotEmpty) {
      int minStart = list.elementAt(0).muteStart;
      for (int x = 1; x < list.length; x++) {
        if (list.elementAt(x).muteStart < minStart) {
          minStart = list.elementAt(x).muteStart;
        }
      }
      minimumStart = minStart;
    }
    for (var element in list) {
      if (element.muteStart == minimumStart) {
        sameStartFilter.add(element);
      }
    }
    if (sameStartFilter.isNotEmpty) {
      int maxEnd = sameStartFilter.elementAt(0).muteEnd;
      for (int x = 1; x < sameStartFilter.length; x++) {
        if (sameStartFilter.elementAt(x).muteEnd > maxEnd) {
          maxEnd = sameStartFilter.elementAt(x).muteEnd;
        }
      }
      maximumEnd = maxEnd;
      List<MuteModel> tempList = [];
      for (var element in list) {
        tempList.add(element);
      }
      for (var element in tempList) {
        if (element.muteStart == minimumStart &&
            element.muteEnd != maximumEnd||(element.muteEnd==maximumEnd&&element.muteStart!=minimumStart)) {
          list.remove(element);
        }
      }
      for (var element in tempList) {
        if (element.muteStart == minimumStart &&
            element.muteEnd == maximumEnd) {
          toReAdd =
              MuteModel(muteStart: element.muteStart, muteEnd: element.muteEnd);
          list.remove(element);
        }
      }
    }
    if (!list.contains(toReAdd!)) {
      list.add(toReAdd);
    }
  }

  static String ffmpegMuteCommand({required List<MuteModel> mutedSections, required int startTrim, required int endTrim}) {
    String command="";
    if(mutedSections.isNotEmpty) {
      command = "-af \"";
      for (var element in mutedSections) {
        int startMute=0;
        int endMute=0;
        if(startTrim!=element.muteStart){
          startMute=element.muteStart-startTrim;
        }else{
          startMute=0;
        }
        if(endTrim!=element.muteEnd){
          endMute=element.muteEnd-startTrim;
        }else{
          endMute=endTrim-startMute;
        }
        command+="volume=enable='between(t,$startMute,$endMute)':volume=0,";
      }
      command= command.substring(0,command.length-1);
      command+="\" -q:v 4 -q:a 4";
    }
    return command;
  }
}
