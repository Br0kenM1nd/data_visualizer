part of 'data_bloc.dart';

abstract class DataEvent extends Equatable {
  const DataEvent();

  @override
  List<Object> get props => [];
}

class DataChooseFiles extends DataEvent {
  const DataChooseFiles();
}

class DataChooseDir extends DataEvent {
  const DataChooseDir();
}
