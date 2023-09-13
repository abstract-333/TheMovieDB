import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:themoviedb/domain/api_client/image_downloader.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';
import 'package:themoviedb/ui/widgets/elements/radial_percent_widget.dart';
import 'package:themoviedb/ui/widgets/movie_details/movie_details_model.dart';

class MovieDetailsMainInfoWidget extends StatelessWidget {
  const MovieDetailsMainInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _TopPostersWidget(),
        Padding(
          padding: EdgeInsets.all(15),
          child: _MovieNameWidget(),
        ),
        _ScoreWidget(),
        _SummaryWidget(),
        Padding(
          padding: EdgeInsets.all(10.0),
          child: _OverViewWidget(),
        ),
        _DescriptionWidget(),
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _PeopleWidgets(),
        ),
      ],
    );
  }
}

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overview =
        context.select((MovieDetailsModel model) => model.data.overview);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Text(
        overview,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _OverViewWidget extends StatelessWidget {
  const _OverViewWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Overview',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _TopPostersWidget extends StatelessWidget {
  const _TopPostersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posterData =
        context.select((MovieDetailsModel model) => model.data.posterData);
    final posterPath = posterData.posterPath;
    final backdropPath = posterData.backdropPath;
    final toggleFavorite = context.read<MovieDetailsModel>().toggleFavorite;
    return AspectRatio(
      aspectRatio: 390 / 219,
      child: Stack(
        children: [
          if (backdropPath != null)
            Image.network(
              ImageDownloader.imageUrl(backdropPath),
              fit: BoxFit.fitWidth,
            ),
          if (posterPath != null)
            Positioned.directional(
                textDirection: TextDirection.ltr,
                top: 20,
                start: 20,
                bottom: 20,
                child: Image.network(ImageDownloader.imageUrl(posterPath))),
          Positioned.directional(
              textDirection: TextDirection.ltr,
              end: 12,
              top: 5,
              child: IconButton(
                splashColor: Colors.red,
                icon: Icon(
                  posterData.isFavorite == true
                      ? Icons.favorite
                      : Icons.favorite_border_rounded,
                  color: Colors.red,
                  size: 30,
                ),
                onPressed: () => toggleFavorite(context),
              )),
        ],
      ),
    );
  }
}

class _MovieNameWidget extends StatelessWidget {
  const _MovieNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data =
        context.select((MovieDetailsModel model) => model.data.nameData);
    return RichText(
      textAlign: TextAlign.center,
      maxLines: 3,
      text: TextSpan(children: [
        TextSpan(
          text: data.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
        ),
        TextSpan(
            text: data.year,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ))
      ]),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  const _ScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreData =
        context.select((MovieDetailsModel model) => model.data.scoreData);
    final trailerKey = scoreData.trailerKey;
    final voteAverage = scoreData.voteAverage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: RadialPercentWidget(
                percent: voteAverage / 100,
                fillColor: const Color.fromARGB(255, 10, 23, 25),
                lineColor: const Color.fromARGB(255, 37, 203, 103),
                feelColor: const Color.fromARGB(255, 25, 54, 31),
                lineWidth: 3,
                child: Text(
                  voteAverage.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'User Score',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        Container(width: 1, height: 15, color: Colors.grey),
        if (trailerKey != null)
          TextButton(
              onPressed: () => Navigator.of(context).pushNamed(
                  MainNavigationNames.movieTrailerWidget,
                  arguments: trailerKey),
              child: Row(
                children: const [
                  Icon(Icons.play_arrow),
                  Text('Player Trailer'),
                ],
              ))
      ],
    );
  }
}

class _SummaryWidget extends StatelessWidget {
  const _SummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summary =
        context.select((MovieDetailsModel model) => model.data.summary);
    return Center(
      child: ColoredBox(
        color: const Color.fromRGBO(22, 21, 25, 1.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Text(
            summary,
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PeopleWidgets extends StatelessWidget {
  const _PeopleWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final crew =
        context.select((MovieDetailsModel model) => model.data.peopleData);
    if (crew.isEmpty) return const SizedBox.shrink();
    return Column(
        children: crew
            .map((chunk) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _PeopleWidgetRow(employees: chunk),
                ))
            .toList());
  }
}

class _PeopleWidgetRow extends StatelessWidget {
  final List<MovieDetailsPeopleData> employees;
  const _PeopleWidgetRow({Key? key, required this.employees}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: employees
          .map((employee) => _PeopleWidgetsRowItem(employee: employee))
          .toList(),
    );
  }
}

class _PeopleWidgetsRowItem extends StatelessWidget {
  final MovieDetailsPeopleData employee;
  const _PeopleWidgetsRowItem({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
    const jobTitleStyle = TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    );
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employee.name, style: nameStyle, maxLines: 2),
          Text(employee.job, style: jobTitleStyle, maxLines: 2),
        ],
      ),
    );
  }
}
