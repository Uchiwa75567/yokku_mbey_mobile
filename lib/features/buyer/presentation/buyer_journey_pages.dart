import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/data/marketplace_models.dart';
import '../../../core/data/marketplace_store.dart';
import '../../../core/widgets/journey_scaffold.dart';
import '../../account/presentation/account_pages.dart';

class BuyerMarketPage extends StatefulWidget {
  const BuyerMarketPage(
      {this.favoritesOnly = false, this.initialCategory = 'Tous', super.key});
  final bool favoritesOnly;
  final String initialCategory;
  @override
  State<BuyerMarketPage> createState() => _BuyerMarketPageState();
}

class BuyerMatchingOffersPage extends StatelessWidget {
  const BuyerMatchingOffersPage({required this.needId, super.key});
  final String needId;
  @override
  Widget build(BuildContext context) {
    final need = MarketplaceScope.of(context).record(needId);
    final matches = need == null
        ? <ProductListing>[]
        : MarketplaceCatalog.products
            .where((p) =>
                p.name.toLowerCase().contains(need.title.toLowerCase()) &&
                p.region == need.region)
            .toList();
    return JourneyScaffold(
        title: 'Offres correspondantes',
        subtitle: need?.title,
        children: [
          const JourneyNotice(
              'Ces offres du catalogue correspondent à votre besoin. Aucune proposition personnalisée de producteur n’a encore été reçue.'),
          if (matches.isEmpty)
            JourneyEmpty(
                title: 'Aucune offre correspondante',
                message: 'Consultez le marché pour élargir votre recherche.',
                action: JourneyButton(
                    label: 'Voir le marché',
                    onPressed: () async =>
                        openJourney(context, '/buyer-products'))),
          ...matches.map((p) => ProductListingCard(product: p)),
        ]);
  }
}

class _BuyerMarketPageState extends State<BuyerMarketPage> {
  String _query = '', _region = MarketplaceCatalog.regions.first;
  late String _category = widget.initialCategory;
  bool _available = false, _sortPrice = false;

  Future<void> _showFilters() async {
    var region = _region;
    var available = _available;
    final apply = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, update) => SafeArea(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Filtrer les produits',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w700))),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                          initialValue: region,
                          isExpanded: true,
                          decoration: const InputDecoration(
                              labelText: 'Région',
                              border: OutlineInputBorder()),
                          items: MarketplaceCatalog.regions
                              .map((r) =>
                                  DropdownMenuItem(value: r, child: Text(r)))
                              .toList(),
                          onChanged: (v) => update(() => region = v!)),
                      const SizedBox(height: 12),
                      SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Disponible maintenant'),
                          value: available,
                          onChanged: (v) => update(() => available = v)),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                          onPressed: () => Navigator.pop(ctx, true),
                          icon: const Icon(Icons.check),
                          label: const Text('Appliquer')),
                    ])))));
    if (apply == true && mounted) {
      setState(() {
        _region = region;
        _available = available;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final products = MarketplaceCatalog.products
        .where((p) =>
            (!widget.favoritesOnly || store.isFavorite(p.id)) &&
            ('${p.name} ${p.producer}'
                .toLowerCase()
                .contains(_query.toLowerCase().trim())) &&
            (_region == MarketplaceCatalog.regions.first ||
                p.region == _region) &&
            (_category == 'Tous' || p.category == _category) &&
            (!_available || (!p.availableSoon && store.remainingStock(p) > 0)))
        .toList();
    if (_sortPrice) products.sort((a, b) => a.unitPrice.compareTo(b.unitPrice));
    return JourneyScaffold(
        title: widget.favoritesOnly ? 'Favoris et alertes' : 'Le marché',
        subtitle: 'Des produits agricoles, directement auprès des producteurs.',
        root: true,
        tab: 1,
        children: [
          Row(children: [
            Expanded(
                child: TextField(
                    decoration: const InputDecoration(
                        hintText: 'Produit ou producteur',
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _query = v))),
            const SizedBox(width: 8),
            IconButton.filledTonal(
                tooltip: 'Filtrer les produits',
                onPressed: _showFilters,
                icon: const Icon(Icons.tune)),
          ]),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: [
                'Tous',
                'Légumes',
                'Fruits',
                'Tubercules',
                'Céréales'
              ]
                      .map((category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) =>
                                  setState(() => _category = category))))
                      .toList())),
          if (widget.favoritesOnly)
            JourneyButton(
                label: 'Gérer mes alertes',
                icon: Icons.notifications_active_outlined,
                onPressed: () async => openJourney(context, '/buyer-alerts')),
          Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  JourneyHeading(
                      '${products.length} produit${products.length > 1 ? 's' : ''}'),
                  Text('$_region${_available ? ' · Disponibles' : ''}',
                      style:
                          const TextStyle(color: journeyMuted, fontSize: 12)),
                ])),
            IconButton(
                tooltip: _sortPrice
                    ? 'Annuler le tri par prix'
                    : 'Trier par prix croissant',
                onPressed: () => setState(() => _sortPrice = !_sortPrice),
                icon: Icon(Icons.sort,
                    color: _sortPrice ? journeyGreen : journeyMuted)),
          ]),
          if (products.isEmpty)
            JourneyEmpty(
                title: 'Aucun produit trouvé',
                message: widget.favoritesOnly
                    ? 'Retrouvez ici les produits que vous ajoutez aux favoris.'
                    : 'Essayez une autre région ou publiez votre besoin.',
                action: JourneyButton(
                    label: 'Publier une demande',
                    onPressed: () async =>
                        openJourney(context, '/publish-buyer-need'))),
          ProductGrid(products: products),
          const JourneyNotice(
              'Catalogue de démonstration. Les disponibilités seront confirmées par les producteurs.'),
        ]);
  }
}

class ProductGrid extends StatelessWidget {
  const ProductGrid({required this.products, super.key});
  final List<ProductListing> products;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth > 600 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: products
                .map((p) => SizedBox(
                    width: width,
                    child: ProductListingCard(product: p, compact: true)))
                .toList());
      });
}

class ProductListingCard extends StatelessWidget {
  const ProductListingCard(
      {required this.product, this.compact = false, super.key});
  final ProductListing product;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.maybeOf(context);
    return JourneyCard(
      padding: EdgeInsets.zero,
      onTap: () =>
          openJourney(context, '/buyer-product-detail', arguments: product.id),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Stack(children: [
          AspectRatio(
              aspectRatio: compact ? 1.55 : 2.2,
              child: Image.asset(product.image, fit: BoxFit.cover)),
          Positioned(
              right: 2,
              top: 2,
              child: IconButton(
                tooltip: store?.isFavorite(product.id) == true
                    ? 'Retirer des favoris'
                    : 'Ajouter aux favoris',
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: journeyGreen),
                onPressed: store == null
                    ? null
                    : () => runJourneyAction(
                        context, () => store.toggleFavorite(product.id)),
                iconSize: 19,
                icon: Icon(store?.isFavorite(product.id) == true
                    ? Icons.favorite
                    : Icons.favorite_border),
              )),
        ]),
        Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: compact ? 14 : 18,
                      fontWeight: FontWeight.w700,
                      color: journeyInk)),
              const SizedBox(height: 5),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: journeyMuted),
                const SizedBox(width: 3),
                Expanded(
                    child: Text(product.region,
                        style:
                            const TextStyle(fontSize: 12, color: journeyMuted)))
              ]),
              const SizedBox(height: 9),
              Text('${formatCfa(product.unitPrice)} / kg',
                  style: TextStyle(
                      fontSize: compact ? 14 : 17,
                      color: journeyGreen,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                  product.availableSoon
                      ? 'Prochaine récolte'
                      : 'Min. ${product.minimum} kg',
                  style: const TextStyle(fontSize: 12, color: journeyMuted)),
            ])),
      ]),
    );
  }
}

class BuyerProductPage extends StatelessWidget {
  const BuyerProductPage({required this.productId, super.key});
  final String productId;
  @override
  Widget build(BuildContext context) =>
      BuyerReservationForm(productId: productId, showProduct: true);
}

class BuyerReservationForm extends StatefulWidget {
  const BuyerReservationForm(
      {required this.productId, this.showProduct = false, super.key});
  final String productId;
  final bool showProduct;
  @override
  State<BuyerReservationForm> createState() => _BuyerReservationFormState();
}

class _BuyerReservationFormState extends State<BuyerReservationForm> {
  final _form = GlobalKey<FormState>();
  late final _quantity = TextEditingController(
      text: '${MarketplaceCatalog.product(widget.productId).minimum}');
  String _recovery = 'Retrait', _address = '';
  bool _consent = false;
  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (!_consent) {
      throw const BusinessException('Confirmez les conditions de réservation.');
    }
    final order = await MarketplaceScope.of(context).reserve(
        productId: widget.productId,
        quantity: int.parse(_quantity.text),
        recovery: _recovery,
        addressId: _address);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
          '/buyer-reservation-confirmation',
          arguments: order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    final p = MarketplaceCatalog.product(widget.productId);
    final addresses = store.records(RecordKind.address);
    final quantity = int.tryParse(_quantity.text) ?? 0;
    final stock = store.remainingStock(p);
    return Form(
        key: _form,
        child: JourneyScaffold(
          title: widget.showProduct
              ? 'Détail du produit'
              : p.availableSoon
                  ? 'Pré-réserver la récolte'
                  : 'Réserver le produit',
          actions: [
            if (widget.showProduct)
              IconButton(
                  tooltip: store.isFavorite(p.id)
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                  onPressed: () => runJourneyAction(
                      context, () => store.toggleFavorite(p.id)),
                  icon: Icon(
                      store.isFavorite(p.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: journeyGreen))
          ],
          leading: widget.showProduct
              ? AspectRatio(
                  aspectRatio: 1.7,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(p.image, fit: BoxFit.cover)))
              : null,
          bottom: JourneyButton(
              label: widget.showProduct
                  ? 'Demander une réservation'
                  : 'Confirmer la réservation',
              icon: Icons.shopping_bag_outlined,
              onPressed: stock < p.minimum ? null : _submit),
          children: [
            if (widget.showProduct)
              Row(children: [
                Icon(Icons.circle,
                    size: 9,
                    color: stock < p.minimum
                        ? journeyMuted
                        : const Color(0xFFE9AD32)),
                const SizedBox(width: 8),
                Text(stock < p.minimum
                    ? 'Indisponible'
                    : p.availableSoon
                        ? 'Prochaine récolte'
                        : 'Disponible'),
              ]),
            Text(p.name,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: journeyInk)),
            Text('${formatCfa(p.unitPrice)} / kg',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: journeyGreen)),
            Text('$stock kg disponibles',
                style: const TextStyle(color: journeyMuted)),
            if (widget.showProduct) ...[
              const Divider(),
              ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0EFE8),
                      child: Icon(Icons.person_outline, color: journeyGreen)),
                  title: Text(p.producer,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.region),
                  trailing: IconButton(
                      tooltip: 'Contacter le producteur',
                      icon: const Icon(Icons.chat_bubble_outline),
                      onPressed: () => showDemoContact(context, p.producer))),
            ],
            const Divider(),
            const JourneyHeading('Votre réservation'),
            const Text('Quantité en kg',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: journeyInk)),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton.outlined(
                  tooltip: 'Diminuer la quantité',
                  onPressed: stock < p.minimum || quantity <= p.minimum
                      ? null
                      : () => setState(() => _quantity.text =
                          '${(quantity - p.minimum).clamp(p.minimum, stock)}'),
                  icon: const Icon(Icons.remove)),
              const SizedBox(width: 8),
              Expanded(
                  child: TextFormField(
                      controller: _quantity,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(suffixText: 'kg'),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final q = int.tryParse(v ?? '') ?? 0;
                        return q < p.minimum || q > stock
                            ? 'Entre ${p.minimum} et $stock kg'
                            : null;
                      })),
              const SizedBox(width: 8),
              IconButton.outlined(
                  tooltip: 'Augmenter la quantité',
                  onPressed: stock < p.minimum || quantity >= stock
                      ? null
                      : () => setState(() => _quantity.text =
                          '${(quantity + p.minimum).clamp(p.minimum, stock)}'),
                  icon: const Icon(Icons.add)),
            ]),
            Text('Minimum : ${p.minimum} kg',
                style: const TextStyle(color: journeyMuted, fontSize: 12)),
            const Text('Récupération',
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: journeyInk)),
            SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'Retrait',
                      label: Text('Retrait'),
                      icon: Icon(Icons.storefront_outlined, size: 18)),
                  ButtonSegment(
                      value: 'Livraison',
                      label: Text('Livraison'),
                      icon: Icon(Icons.local_shipping_outlined, size: 18)),
                ],
                showSelectedIcon: false,
                selected: {_recovery},
                style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: const Color(0xFFE0EFE8),
                    selectedForegroundColor: journeyGreen,
                    side: const BorderSide(color: journeyBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onSelectionChanged: (v) =>
                    setState(() => _recovery = v.single)),
            if (_recovery == 'Livraison') ...[
              if (addresses.isNotEmpty)
                DropdownButtonFormField<String>(
                    initialValue: addresses.any((a) => a.id == _address)
                        ? _address
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Adresse de livraison'),
                    items: addresses
                        .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text('${a.title} · ${a.region}',
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _address = v ?? ''),
                    validator: (v) =>
                        v == null ? 'Choisissez une adresse' : null),
              OutlinedButton.icon(
                  onPressed: () => openJourney(context, '/buyer-address-form'),
                  icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                  label: const Text('Ajouter une adresse')),
              const Text('Frais de livraison à convenir, non inclus.',
                  style: TextStyle(fontSize: 12, color: journeyMuted)),
            ],
            const Divider(),
            Row(children: [
              const Expanded(
                  child: Text('Total estimé',
                      style: TextStyle(fontWeight: FontWeight.w600))),
              Flexible(
                  child: Text(formatCfa(quantity * p.unitPrice),
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: journeyGreen))),
            ]),
            const Text('Sous réserve de confirmation du producteur.',
                style: TextStyle(fontSize: 12, color: journeyMuted)),
            CheckboxListTile(
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                    'Je comprends que ma réservation attend la confirmation du producteur.',
                    style: TextStyle(fontSize: 13, color: journeyMuted))),
          ],
        ));
  }
}

class BuyerReservationSuccess extends StatelessWidget {
  const BuyerReservationSuccess({required this.orderId, super.key});
  final String orderId;
  @override
  Widget build(BuildContext context) {
    final order = MarketplaceScope.of(context).record(orderId);
    return JourneyScaffold(title: 'Réservation enregistrée', children: [
      const Icon(Icons.check_circle_outline,
          size: 64, color: Color(0xFFACEDBB)),
      if (order != null)
        JourneyCard(
            child: Text(
                '${order.title}\n${order.quantity} kg · ${formatCfa(order.amount)}\n${order.id}',
                style: const TextStyle(height: 1.8))),
      const JourneyNotice(
          'En attente du producteur. Aucun paiement n’a été prélevé.'),
      JourneyButton(
          label: 'Suivre ma réservation',
          onPressed: () async => Navigator.of(context).pushReplacementNamed(
              '/buyer-order-tracking',
              arguments: orderId)),
      JourneyButton(
          label: 'Voir mes achats',
          icon: Icons.shopping_basket_outlined,
          onPressed: () async => openJourneyTab(context, '/buyer-purchases')),
    ]);
  }
}

class BuyerNeedsForm extends StatefulWidget {
  const BuyerNeedsForm({this.needId, super.key});
  final String? needId;
  @override
  State<BuyerNeedsForm> createState() => _BuyerNeedsFormState();
}

class _BuyerNeedsFormState extends State<BuyerNeedsForm> {
  final _form = GlobalKey<FormState>();
  final _product = TextEditingController(),
      _quantity = TextEditingController(),
      _budget = TextEditingController(),
      _details = TextEditingController();
  String _region = 'Dakar', _unit = 'kg';
  DateTime _date =
      DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1));
  bool _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final old = MarketplaceScope.of(context).record(widget.needId ?? '');
    if (old != null) {
      _product.text = old.title;
      _quantity.text = '${old.quantity}';
      _budget.text = '${old.amount}';
      _details.text = old.details;
      _region = old.region;
      _unit = old.attributes['unit']!;
      _date = DateTime.parse(old.attributes['date']!);
    }
  }

  @override
  void dispose() {
    for (final c in [_product, _quantity, _budget, _details]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = MarketplaceScope.of(context);
    return Form(
        key: _form,
        child: JourneyScaffold(
            title: widget.needId == null
                ? 'Publier une demande'
                : 'Modifier ma demande',
            children: [
              JourneyField(label: 'Produit recherché', controller: _product),
              JourneyField(
                  label: 'Quantité', controller: _quantity, number: true),
              JourneySelect(
                  label: 'Unité',
                  value: _unit,
                  values: const ['kg', 'tonnes', 'sacs'],
                  onChanged: (v) => setState(() => _unit = v)),
              JourneySelect(
                  label: 'Région',
                  value: _region,
                  values: MarketplaceCatalog.regions.skip(1).toList(),
                  onChanged: (v) => setState(() => _region = v)),
              JourneyField(
                  label: 'Budget total en FCFA',
                  controller: _budget,
                  number: true),
              JourneyCard(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: const Text('Date souhaitée'),
                      subtitle: Text(formatDate(_date)),
                      onTap: () async {
                        final now = DateUtils.dateOnly(DateTime.now());
                        final date = await showDatePicker(
                            context: context,
                            initialDate: _date.isBefore(now) ? now : _date,
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 730)));
                        if (date != null && mounted) {
                          setState(() => _date = date);
                        }
                      })),
              JourneyField(
                  label: 'Précisions (facultatif)',
                  controller: _details,
                  lines: 3,
                  required: false),
              JourneyButton(
                  label: widget.needId == null
                      ? 'Publier ma demande'
                      : 'Enregistrer les modifications',
                  icon: Icons.check,
                  onPressed: () async {
                    if (!_form.currentState!.validate()) return;
                    await store.saveNeed(
                        id: widget.needId,
                        title: _product.text,
                        quantity: int.parse(_quantity.text),
                        unit: _unit,
                        region: _region,
                        budget: int.parse(_budget.text),
                        date: _date,
                        details: _details.text);
                    if (context.mounted) {
                      Navigator.of(context)
                          .pushReplacementNamed('/buyer-needs');
                    }
                  }),
            ]));
  }
}

class BuyerRecordsPage extends StatefulWidget {
  const BuyerRecordsPage({required this.kind, super.key});
  final RecordKind kind;
  @override
  State<BuyerRecordsPage> createState() => _BuyerRecordsPageState();
}

class _BuyerRecordsPageState extends State<BuyerRecordsPage> {
  String _filter = 'Tous';
  @override
  Widget build(BuildContext context) {
    final isOrder = widget.kind == RecordKind.order;
    final all = MarketplaceScope.of(context).records(widget.kind);
    final records = all
        .where((r) => _filter == 'Tous' || r.status.label == _filter)
        .toList();
    final filters = ['Tous', ...all.map((r) => r.status.label).toSet()];
    return JourneyScaffold(
        title: isOrder ? 'Mes achats' : 'Mes demandes',
        tab: isOrder ? 2 : 0,
        root: isOrder,
        children: [
          if (!isOrder)
            JourneyButton(
                label: 'Nouvelle demande',
                icon: Icons.add,
                onPressed: () async =>
                    openJourney(context, '/publish-buyer-need')),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map((f) => ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f)))
                  .toList()),
          if (records.isEmpty)
            JourneyEmpty(
                title:
                    isOrder ? 'Aucun achat pour le moment' : 'Aucune demande',
                message: isOrder
                    ? 'Vos réservations et leur suivi apparaîtront ici.'
                    : 'Publiez votre besoin pour préparer votre prochain achat.',
                action: JourneyButton(
                    label:
                        isOrder ? 'Voir les produits' : 'Publier une demande',
                    onPressed: () async => openJourney(context,
                        isOrder ? '/buyer-products' : '/publish-buyer-need'))),
          ...records.map((r) => RecordTile(
              record: r,
              onTap: () => openJourney(context,
                  isOrder ? '/buyer-order-tracking' : '/buyer-need-detail',
                  arguments: r.id))),
        ]);
  }
}
