import 'package:flutter/material.dart';
import 'package:giphy/gif_model.dart';
import 'package:giphy/repository.dart'; // contains GifRepo

class GiphyPage extends StatefulWidget {
  const GiphyPage({super.key, required this.repo});
  final GifRepo repo;

  @override
  State<GiphyPage> createState() => _GiphyPageState();
}

class _GiphyPageState extends State<GiphyPage> {
  final _items = <GifData>[];
  final _controller = ScrollController();
  final _searchCtrl = TextEditingController();

  int _offset = 0;
  int _total = 1;
  bool _loading = false;
  String _query = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 300) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _offset = 0;
        _total = 1;
        _items.clear();
      }
    });

    try {
      const pageSize = 30;
      if (_offset >= _total) {
        setState(() => _loading = false);
        return;
      }
      final result = _query.isEmpty
          ? await widget.repo.trending(offset: _offset, limit: pageSize)
          : await widget.repo.search(
          query: _query, offset: _offset, limit: pageSize);
      final (items, total) = result;
      setState(() {
        _items.addAll(items);
        _offset += items.length;
        _total = total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSubmit(String q) {
    _query = q.trim();
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIPHY'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search GIFs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSubmit,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [
                TextButton(
                  onPressed: () => _load(reset: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(
            child: GridView.builder(
              controller: _controller,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _items.length + (_loading ? 6 : 0),
              itemBuilder: (_, i) {
                if (i >= _items.length) {
                  return const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x11000000)),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final gif = _items[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    gif.previewUrl,
                    fit: BoxFit.cover,
                    headers: const {'accept': 'image/*'},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
