import 'package:flutter/material.dart';
import '../models/airport.dart';
import '../data/airport/airport_lookup.dart';
import '../localization/language_constants.dart';

class AirportSearchDelegate extends SearchDelegate<Airport> {
  AirportSearchDelegate({required this.airportLookup});
  final AirportLookup airportLookup;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6:
            TextStyle(fontWeight: FontWeight.normal, color: Colors.white),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildMatchingSuggestions(context);
  }

  Widget buildMatchingSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    final searched = airportLookup.searchString(query);
    if (searched.length == 0) {
      return AirportSearchPlaceholder(
          title: getTranslatedValues(context, 'no_result'));
    }

    return ListView.builder(
      itemCount: searched.length,
      itemBuilder: (context, index) {
        return AirportSearchResultTile(
          airport: searched[index],
          searchDelegate: this,
        );
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : <Widget>[
            IconButton(
              tooltip: getTranslatedValues(context, 'no_result'),
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          ];
  }
}

class AirportSearchPlaceholder extends StatelessWidget {
  AirportSearchPlaceholder({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline4,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AirportSearchResultTile extends StatelessWidget {
  const AirportSearchResultTile(
      {required this.airport, required this.searchDelegate});

  final Airport airport;
  final SearchDelegate<Airport> searchDelegate;

  @override
  Widget build(BuildContext context) {
    final title = '${airport.name} (${airport.iata})';
    final subtitle = '${airport.city}, ${airport.country}';
    return ListTile(
      dense: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.start,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyText1,
        textAlign: TextAlign.start,
      ),
      onTap: () => searchDelegate.close(context, airport),
    );
  }
}
