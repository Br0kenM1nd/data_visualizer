part of 'explorer_bloc.dart';

abstract class ExplorerState extends Equatable {
  const ExplorerState();
}

class ExplorerInitial extends ExplorerState {
  const ExplorerInitial();

  @override
  List<Object> get props => [];
}

class ExplorerLasOpenSuccessfully extends ExplorerState {
  final List<FlSpot> points;

  const ExplorerLasOpenSuccessfully(this.points);

  @override
  List<Object> get props => [points];
}

class ExplorerError extends ExplorerState {
  final Exception error;

  const ExplorerError(this.error);

  @override
  List<Object> get props => [error];
}
