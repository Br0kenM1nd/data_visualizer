part of 'data_bloc.dart';

abstract class DataState extends Equatable {
  const DataState();
}

class DataInitial extends DataState {
  const DataInitial();

  @override
  List<Object> get props => [];
}

class DataParsed extends DataState {
  final List<Data> list;

  const DataParsed({required this.list});

  @override
  List<Object> get props => [list];
}

class DataError extends DataState {
  final Exception error;

  const DataError(this.error);

  @override
  List<Object> get props => [error];
}
