import 'package:Wavelet/models/wavelet_device.dart';
import 'package:Wavelet/pages/initalpair/inital-pair_page.dart';
import 'package:Wavelet/services/device_service.dart';
import 'package:Wavelet/theme/colors.dart';
import 'package:Wavelet/util/function/ble_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.toggleTheme});

  final VoidCallback toggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DeviceService _deviceService = DeviceService();
  String? _selectedDeviceId;

  Stream<QuerySnapshot<Map<String, dynamic>>>? get _deviceSnapshots {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = _deviceSnapshots;

    return Scaffold(
      backgroundColor: WaveletColors.background(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: snapshots == null
                  ? _buildDashboard(const [])
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: snapshots,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildLoadError();
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: WaveletColors.primary(context),
                            ),
                          );
                        }

                        final devices = (snapshot.data?.docs ?? [])
                            .map(_DashboardDevice.fromDocument)
                            .toList();
                        return _buildDashboard(devices);
                      },
                    ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(List<_DashboardDevice> devices) {
    final onlineCount = devices.where((device) => device.isOnline).length;
    final playingDevices = devices
        .where((device) => device.isPlaying && device.trackTitle != null)
        .toList();
    final selected = devices.cast<_DashboardDevice?>().firstWhere(
      (device) => device?.id == _selectedDeviceId,
      orElse: () => devices.isEmpty ? null : devices.first,
    );
    final selectedPlayback =
        selected != null && selected.isPlaying && selected.trackTitle != null
        ? selected
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth.clamp(0.0, 430.0);
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 40,
            bottom: 20,
            left: (constraints.maxWidth - pageWidth) / 2,
            right: (constraints.maxWidth - pageWidth) / 2,
          ),
          child: Center(
            child: SizedBox(
              width: pageWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildStatusSummary(
                      onlineCount: onlineCount,
                      playingCount: playingDevices.length,
                      deviceCount: devices.length,
                    ),
                    if (playingDevices.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      for (
                        var index = 0;
                        index < playingDevices.length;
                        index++
                      ) ...[
                        if (index > 0) const SizedBox(height: 14),
                        _buildNowPlayingCard(playingDevices[index]),
                      ],
                    ] else if (selectedPlayback != null) ...[
                      const SizedBox(height: 28),
                      _buildNowPlayingCard(selectedPlayback),
                    ],
                    const SizedBox(height: 18),
                    _buildDevicesHeading(),
                    const SizedBox(height: 20),
                    if (devices.isEmpty)
                      _buildEmptyState()
                    else
                      for (var index = 0; index < devices.length; index++) ...[
                        if (index > 0) const SizedBox(height: 22),
                        _buildDeviceCard(devices[index]),
                      ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : hour < 17
        ? 'Good afternoon,'
        : 'Good evening,';
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim().split(' ').first
        : 'Serenity';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: WaveletColors.textSecondary(context),
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: WaveletColors.textPrimary(context),
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
          background: WaveletColors.surfaceVariant(context),
          foreground: WaveletColors.accent(context),
          size: 36,
        ),
        const SizedBox(width: 10),
        CircleAvatar(
          radius: 18,
          backgroundColor: WaveletColors.primary(context),
          child: Icon(
            Icons.person_outline_rounded,
            size: 21,
            color: WaveletColors.secondaryButtonText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummary({
    required int onlineCount,
    required int playingCount,
    required int deviceCount,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: WaveletColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: WaveletColors.success(context),
                  shape: BoxShape.circle,
                ),
              ),
              label: '$onlineCount online',
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _SummaryItem(
              icon: Icon(
                Icons.music_note_rounded,
                size: 13,
                color: WaveletColors.primaryButton(context),
              ),
              label: '$playingCount playing',
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _SummaryItem(
              icon: Icon(
                Icons.speaker_outlined,
                size: 13,
                color: WaveletColors.accent(context),
              ),
              label: '$deviceCount devices',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() => Container(
    width: 1,
    height: 15,
    color: WaveletColors.divider(context),
    margin: const EdgeInsets.symmetric(horizontal: 7),
  );

  Widget _buildNowPlayingCard(_DashboardDevice device) {
    final song = device.trackTitle ?? 'Nothing playing';
    final artist = device.trackArtist ?? 'Connect a Wavelet to see playback';

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: WaveletColors.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: WaveletColors.primaryButton(context).withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: WaveletColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: WaveletColors.border(context)),
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 21,
              color: WaveletColors.textPrimary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOW PLAYING  ·  ${device.modelLabel.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: WaveletColors.textPrimary(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  song,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: WaveletColors.textPrimary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: WaveletColors.textSecondary(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: device.isPlaying ? 'Pause' : 'Play',
            onPressed: device.model.toLowerCase() == 'mini'
                ? () => _toggleMiniPlayback(device)
                : null,
            style: IconButton.styleFrom(
              backgroundColor: WaveletColors.surfaceVariant(context),
            ),
            icon: Icon(
              device.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: WaveletColors.accent(context),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesHeading() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'My Devices',
            style: TextStyle(
              color: WaveletColors.textPrimary(context),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: WaveletColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: _addWavelet,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 14,
                    color: WaveletColors.primaryButton(context),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: WaveletColors.primaryButton(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard(_DashboardDevice device) {
    final isSelected = _selectedDeviceId == device.id;
    final statusColor = device.isOnline
        ? WaveletColors.success(context)
        : WaveletColors.warning(context);
    final status = device.isOnline
        ? (device.isPlaying ? 'Playing' : 'Online')
        : 'Offline';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => setState(() => _selectedDeviceId = device.id),
        onLongPress: () => _editDeviceName(device),
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          decoration: BoxDecoration(
            color: WaveletColors.surfaceVariant(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? WaveletColors.primary(context).withValues(alpha: 0.45)
                  : WaveletColors.surfaceVariant(context),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          child: Column(
            children: [
              Row(
                children: [
                  _SpeakerIllustration(statusColor: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: WaveletColors.textPrimary(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _ModelBadge(label: device.modelLabel),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$status  ·  ${device.volumePercent}% Volume',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: device.isOnline
                                ? WaveletColors.textSecondary(context)
                                : WaveletColors.textDisabled(context),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Rename ${device.name}',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _editDeviceName(device),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: WaveletColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(height: 1, color: WaveletColors.divider(context)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.equalizer_rounded,
                    color: WaveletColors.textSecondary(context),
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      device.trackTitle == null
                          ? 'Nothing playing'
                          : '${device.trackTitle} — ${device.trackArtist ?? 'Unknown artist'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: WaveletColors.textSecondary(context),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: WaveletColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WaveletColors.border(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.speaker_group_outlined,
            color: WaveletColors.accent(context),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            'No Wavelets linked yet',
            style: TextStyle(
              color: WaveletColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a Wavelet to see it here.',
            style: TextStyle(
              color: WaveletColors.textSecondary(context),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          _AddWaveletButton(onPressed: _addWavelet),
        ],
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: WaveletColors.error(context)),
            const SizedBox(height: 12),
            Text(
              'Could not load your Wavelets',
              textAlign: TextAlign.center,
              style: TextStyle(color: WaveletColors.textPrimary(context)),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {}),
              child: Text(
                'Try again',
                style: TextStyle(color: WaveletColors.primary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewPaddingOf(context).bottom > 0 ? 8 : 20,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: WaveletColors.surface(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: WaveletColors.surfaceVariant(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _NavigationItem(
                label: 'My Devices',
                icon: Icons.speaker_outlined,
                onTap: _addWavelet,
              ),
            ),
            Expanded(
              child: _NavigationItem(
                label: 'Home',
                icon: Icons.home_outlined,
                selected: true,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _NavigationItem(
                label: 'Settings',
                icon: Icons.settings_rounded,
                onTap: widget.toggleTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addWavelet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InitialPair(toggleTheme: widget.toggleTheme),
      ),
    );
  }

  Future<void> _toggleMiniPlayback(_DashboardDevice device) async {
    try {
      await bleManager.reconnectFromId(device.id);
      await bleManager.sendCommand('PLAY_PAUSE');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: const StadiumBorder(),
          backgroundColor: WaveletColors.error(context),
          content: Text(
            'Could not reach ${device.name}. Move closer and try again.',
          ),
        ),
      );
    }
  }

  Future<void> _editDeviceName(_DashboardDevice device) async {
    final controller = TextEditingController(text: device.name);
    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: WaveletColors.surfaceVariant(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Rename Wavelet',
          style: TextStyle(color: WaveletColors.textPrimary(dialogContext)),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 32,
          style: TextStyle(color: WaveletColors.textPrimary(dialogContext)),
          decoration: InputDecoration(
            hintText: 'Device name',
            hintStyle: TextStyle(
              color: WaveletColors.textDisabled(dialogContext),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: WaveletColors.border(dialogContext),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: WaveletColors.primary(dialogContext),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: WaveletColors.textSecondary(dialogContext),
              ),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(color: WaveletColors.primary(dialogContext)),
            ),
          ),
        ],
      ),
    );
    controller.dispose();

    if (updatedName == null || updatedName.isEmpty) return;

    try {
      await _deviceService.updateDevice(
        WaveletDevice(
          id: device.id,
          model: device.model,
          name: updatedName,
          color: device.color,
          firmwareVersion: device.firmwareVersion,
          pairedAt: device.pairedAt,
          lastSeen: device.lastSeen,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: WaveletColors.surfaceVariant(context),
          shape: StadiumBorder(
            side: BorderSide(color: WaveletColors.border(context)),
          ),
          content: Text(
            'Could not save the Wavelet name.',
            style: TextStyle(color: WaveletColors.textPrimary(context)),
          ),
        ),
      );
    }
  }
}

class _DashboardDevice {
  const _DashboardDevice({
    required this.id,
    required this.model,
    required this.name,
    required this.isOnline,
    required this.isPlaying,
    required this.trackTitle,
    required this.trackArtist,
    required this.volumePercent,
    required this.color,
    required this.firmwareVersion,
    required this.pairedAt,
    required this.lastSeen,
  });

  final String id;
  final String model;
  final String name;
  final bool isOnline;
  final bool isPlaying;
  final String? trackTitle;
  final String? trackArtist;
  final int volumePercent;
  final String? color;
  final String? firmwareVersion;
  final DateTime? pairedAt;
  final DateTime? lastSeen;

  String get modelLabel {
    final normalized = model.toLowerCase();
    if (normalized.contains('mini')) return 'MINI';
    if (normalized.contains('max')) return 'MAX';
    return 'WAVELET';
  }

  factory _DashboardDevice.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final device = WaveletDevice.fromFirestore(document.id, data);
    final lastSeen = device.lastSeen;
    final lastSeenRecently =
        lastSeen != null &&
        DateTime.now().difference(lastSeen).abs() <= const Duration(minutes: 2);
    final title = _firstString(data, const [
      'trackTitle',
      'songTitle',
      'currentTrack',
      'track',
    ]);
    final isPlaying =
        data['isPlaying'] == true ||
        data['playing'] == true ||
        data['playbackState']?.toString().toLowerCase() == 'playing';

    return _DashboardDevice(
      id: device.id,
      model: device.model,
      name: device.name,
      isOnline: data['isOnline'] == true || lastSeenRecently,
      isPlaying: isPlaying,
      trackTitle: title,
      trackArtist: _firstString(data, const [
        'trackArtist',
        'songArtist',
        'artist',
      ]),
      volumePercent: _parseVolume(data['volumePercent'] ?? data['volume']),
      color: device.color,
      firmwareVersion: device.firmwareVersion,
      pairedAt: device.pairedAt,
      lastSeen: device.lastSeen,
    );
  }

  static String? _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static int _parseVolume(Object? value) {
    final parsed = value is num ? value.round() : int.tryParse('$value') ?? 0;
    return parsed.clamp(0, 100);
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: WaveletColors.textPrimary(context),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeakerIllustration extends StatelessWidget {
  const _SpeakerIllustration({required this.statusColor});

  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 42,
            decoration: BoxDecoration(
              color: WaveletColors.surface(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WaveletColors.border(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 2.5,
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: WaveletColors.accent(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 10,
                  height: 3,
                  decoration: BoxDecoration(
                    color: WaveletColors.primary(context),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: WaveletColors.primary(
                          context,
                        ).withValues(alpha: 0.55),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: WaveletColors.surfaceVariant(context),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.45),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelBadge extends StatelessWidget {
  const _ModelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: WaveletColors.info(context).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: WaveletColors.textSecondary(context),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.35,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    required this.background,
    required this.foreground,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foreground, size: 18),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? WaveletColors.secondaryButtonText(context)
        : WaveletColors.textSecondary(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 30,
            decoration: BoxDecoration(
              color: selected
                  ? WaveletColors.primary(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: selected
                  ? WaveletColors.success(context)
                  : WaveletColors.textSecondary(context),
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddWaveletButton extends StatelessWidget {
  const _AddWaveletButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: WaveletColors.primaryButton(context),
        foregroundColor: WaveletColors.primaryButtonText(context),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      ),
      icon: const Icon(Icons.add_rounded, size: 16),
      label: const Text('Add Wavelet'),
    );
  }
}
