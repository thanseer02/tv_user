import 'package:base_project/features/demo_listing/view_model/demo_listing_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/extensions.dart';

class DemoListingScreen extends StatefulWidget {
  static const routeName = '/DemoListingScreen';

  const DemoListingScreen({super.key});

  @override
  State<DemoListingScreen> createState() => _DemoListingScreenState();
}

class _DemoListingScreenState extends State<DemoListingScreen> {
  final ScrollController _scrollController = ScrollController();
  late final DemoListingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DemoListingViewModel();
    Future.delayed(const Duration(seconds: 1), () {
      _viewModel.loadItems(initialCall: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Demo Listing Screen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<DemoListingViewModel>(
            builder: (context, vm, child) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => vm.loadItems(initialCall: true),
                        child: const Text('Refresh'),
                      ),
                      Text('Page ${vm.pagination.page}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: vm.items.length + 1,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index < vm.items.length) {
                          return ListTile(
                            title: Text(vm.items[index]),
                          );
                        }

                        if (vm.pagination.canLoadMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }

                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('No more items'),
                          ),
                        );
                      },
                    )
                        .withLoadMore(
                          canLoadMore: (context) => vm.pagination.canLoadMore,
                          onLoadMore: (context) => vm.loadItems(),
                        )
                        .orShowEmptyWidget(
                          items: vm.items,
                          isLoading: vm.isLoading,
                          text: 'No demo data available',
                        ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
