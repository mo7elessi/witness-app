import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_shot/core/themes/app_theme.dart';
import 'package:nice_shot/core/util/enums.dart';
import 'package:nice_shot/data/model/api/User_model.dart';
import 'package:nice_shot/logic/ui_bloc/ui_bloc.dart';
import 'package:nice_shot/presentation/features/profile/bloc/user_bloc.dart';
import 'package:nice_shot/presentation/features/profile/widgets/user_info_widget.dart';
import 'package:nice_shot/presentation/widgets/error_widget.dart';
import 'package:nice_shot/presentation/widgets/loading_widget.dart';
import 'package:nice_shot/presentation/widgets/secondary_button_widget.dart';
import 'package:nice_shot/presentation/widgets/user_image_widget.dart';
import '../../../../core/routes/routes.dart';
import '../../../widgets/snack_bar_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state.requestState == RequestState.loading) {
          return const LoadingWidget();
        } else if (state.requestState == RequestState.loaded) {
          UserModel? user = state.user!.data;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(MySizes.widgetSideSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BlocConsumer<UiBloc, UiState>(
                        listener: (context, state) {
                          final file = state.profileImage;
                          if (file != null) {
                            context
                                .read<UserBloc>()
                                .add(UpdateUserImageEvent(path: file.path));
                          }
                        },
                        builder: (context, state) {
                          return context
                                      .read<UserBloc>()
                                      .state
                                      .updateImageState ==
                                  RequestState.loading
                              ? const LoadingWidget()
                              : BlocConsumer<UserBloc, UserState>(
                                  listener: (context, state) {
                                    if (state.updateImageState ==
                                            RequestState.error ||
                                        state.updateImageState ==
                                            RequestState.loaded) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        snackBarWidget(message: state.message!),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        UserImageWidget(
                                            imageUri: "${user?.logoUrl}"),
                                        InkWell(
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                                MySizes.verticalSpace),
                                            decoration: BoxDecoration(
                                              color: MyColors.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      MySizes.imageRadius),
                                            ),
                                            child: const Icon(Icons.camera_alt,
                                                color: Colors.white),
                                          ),
                                          onTap: () =>
                                              context.read<UiBloc>().add(
                                                    PickProfileImageEvent(),
                                                  ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                        },
                      ),
                      const SizedBox(height: MySizes.verticalSpace),
                      Text(
                        "${user?.name}",
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: MySizes.verticalSpace / 2),
                      Text(
                        "${user?.userName}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: MySizes.verticalSpace),
                  UserInfoWidget(text: "Mobile", info: user?.mobile),
                  const SizedBox(height: MySizes.verticalSpace),
                  UserInfoWidget(text: "Email", info: user?.email),
                  const SizedBox(height: MySizes.verticalSpace),
                  UserInfoWidget(text: "Birth Date", info: user?.birthDate),
                  const SizedBox(height: MySizes.verticalSpace),
                  UserInfoWidget(
                    text: "Nationality",
                    info: user?.nationality,
                  ),
                  const SizedBox(height: MySizes.verticalSpace * 3),
                  SecondaryButtonWidget(
                    function: () =>
                        Navigator.pushNamed(context, Routes.editProfilePage),
                    text: "edit profile",
                  )
                ],
              ),
            ),
          );
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
    );
  }
}
