part of 'explorer_bloc.dart';

abstract class ExplorerEvent extends Equatable {
  const ExplorerEvent();
}

class ExplorerFilePressed extends ExplorerEvent {
  const ExplorerFilePressed();

  @override
  List<Object> get props => [];
}