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
import '../../../../core/routes/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            BlocConsumer<UiBloc, UiState>(
                              listener: (context, state) {
                                final file = state.file;
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
                                    : Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                              height: MySizes.imageHeight,
                                              width: MySizes.imageWidth,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          MySizes.imageRadius),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      "${user?.logoUrl}",
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ))),
                                          InkWell(
                                            child: Container(
                                              padding: const EdgeInsets.all(
                                                  MySizes.verticalSpace),
                                              decoration: BoxDecoration(
                                                color: MyColors.primaryColor,
                                                borderRadius: BorderRadius.circular(
                                                    MySizes.imageRadius),
                                              ),
                                              child: const Icon(Icons.camera_alt,
                                                  color: Colors.white),
                                            ),
                                            onTap: () =>
                                                context.read<UiBloc>().add(
                                                      PickUserImageEvent(),
                                                    ),
                                          ),
                                        ],
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
                      ),
                      const SizedBox(height: MySizes.verticalSpace),
                      UserInfoWidget(text: "Mobile", info: user?.mobile),
                      const SizedBox(height: MySizes.verticalSpace),
                      UserInfoWidget(text: "Email", info: user?.email),
                      const SizedBox(height: MySizes.verticalSpace),
                      UserInfoWidget(text: "Birth Date", info: user?.birthDate),
                      const SizedBox(height: MySizes.verticalSpace),
                      UserInfoWidget(text: "Nationality", info: user?.nationality),
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
              return ErrorMessageWidget(message: state.message ?? "Unknown Error");
            }
            return const LoadingWidget();
          },
        );
      }
    );
  }
}
