import 'package:attendance/screens/lectuers_screen.dart';
import 'package:flutter/material.dart';

import '../../core/resources/app_colors.dart';
import 'widgets/custom_app_bar.dart';

class HomeScreens extends StatelessWidget {
  const HomeScreens({super.key});
  @override
  Widget build(BuildContext context) {
    final List<String> className = [
      "fundamental of programming ",
      "Object-oriented programming ",
      "Data Structures",
      "Algorithmes",
      "DataBase Administration",
      "Big Data",
    ];

    return Scaffold(
        body: CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: AppBarWidge(
           // title: "الصفحه الرئيسيه",
           title: "",
            imagePath: "assets/images/logo.png",
           // nameUser: "اهلاً ,  د. محمد خفاجي",
           // nameUser: "اهلاً ,  د. محمد خفاجي",
              nameUser:  "الصفحه الرئيسيه",
          ),
        ),
        SliverToBoxAdapter(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: className.length,
            itemBuilder: (context, index) {
              var indexImgae = index;
              if (index > 6) indexImgae = index % 6;

              return SizedBox(
                height: MediaQuery.sizeOf(context).height * .17,
                child: Stack(children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LecturesScreen(title: className[index]),
                        ),
                      );
                    },
                    child: Container(
                      height: MediaQuery.sizeOf(context).height * .17,
                      margin: const EdgeInsets.all(10),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                          // color: Colors.blue.shade300,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              opacity: .8,
                              fit: BoxFit.fitWidth,
                              image: AssetImage(
                                  "assets/images/imageClass$indexImgae.jpg"))),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        className[index],
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: AppColors.colorWhite),
                      ),
                    ),
                  )
                ]),
              );
            },
          ),
        )
      ],
    ));
  }
}
