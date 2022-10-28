import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/video_model.dart';
import 'package:nice_shot/presentation/widgets/error_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/uploaded_video_item.dart';
import '../bloc/edited_video_bloc.dart';
import '../../../widgets/empty_video_list_widget.dart';

class UploadedEditedVideoPage extends StatelessWidget {
  const UploadedEditedVideoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MySizes.verticalSpace),
      child: BlocBuilder<EditedVideoBloc, EditedVideoState>(
        builder: (context, state) {
          if (state.requestState == RequestState.loading) {
            return const LoadingWidget();
          } else if (state.requestState == RequestState.loaded) {
            return state.data!.data!.isNotEmpty
                ? GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1 / 1.3,
                    children: List.generate(state.data!.data!.length, (index) {
                      VideoModel data = state.data!.data![index];
                      return UploadedVideoItem(
                        videoModel: data,
                        isEditedVideo: true,
                      );
                    }),
                  )
                : const EmptyVideoListWidget();
          } else if (state.requestState == RequestState.error) {
            return Center(
              child: ErrorMessageWidget(
                message: state.message!,
                isAction: true,
              ),
            );
          }
          return const LoadingWidget();
        },
      ),
    );
  }
}
