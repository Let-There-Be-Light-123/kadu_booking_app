import 'package:bloc/bloc.dart';

// Events
abstract class FavoriteEvent {}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String id;

  ToggleFavoriteEvent(this.id);
}

// States
abstract class FavoriteState {}

class FavoriteInitialState extends FavoriteState {}

class FavoriteUpdatedState extends FavoriteState {
  final Map<String, bool> favorites;

  FavoriteUpdatedState(this.favorites);
}

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitialState());

  Map<String, bool> _favorites = {};

  @override
  Stream<FavoriteState> mapEventToState(FavoriteEvent event) async* {
    if (event is ToggleFavoriteEvent) {
      _favorites[event.id] = !_favorites[event.id]!;
      yield FavoriteUpdatedState(Map.from(_favorites));
    }
  }
}
