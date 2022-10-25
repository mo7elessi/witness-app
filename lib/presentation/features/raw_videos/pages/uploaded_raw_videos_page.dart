import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/presentation/features/raw_videos/bloc/raw_video_bloc.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';

import '../../../../core/util/my_box_decoration.dart';
import '../../../widgets/uploaded_video_item.dart';
import '../../video_player/video_player_page.dart';
import '../../../widgets/empty_video_list_widget.dart';

class UploadedRawEditedVideoPage extends StatelessWidget {
  const UploadedRawEditedVideoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySizes.widgetSideSpace),
      child: BlocBuilder<RawVideoBloc, RawVideoState>(
        builder: (context, state) {
          if (state.requestState == RequestState.loading) {
            return const LoadingWidget();
          } else if (state.requestState == RequestState.loaded) {
            if (state.data!.data != null) {
              return state.data!.data!.isNotEmpty
                  ? GridView.count(
                      shrinkWrap: true,
                      //physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                      childAspectRatio: 1 / 1,
                      children:
                          List.generate(state.data!.data!.length, (index) {
                        VideoModel data = state.data!.data![index];

                        return UploadedVideoItem(
                          videoModel: data,
                          isEditedVideo: false,
                        );
                      }),
                    )
                  : const EmptyVideoListWidget();
            }
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}
