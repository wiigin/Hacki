import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hacki/blocs/blocs.dart';
import 'package:hacki/cubits/cubits.dart';
import 'package:hacki/extensions/extensions.dart';
import 'package:hacki/models/models.dart';
import 'package:hacki/screens/widgets/bloc_builder_3.dart';
import 'package:hacki/screens/widgets/centered_text.dart';
import 'package:hacki/services/services.dart';
import 'package:hacki/styles/styles.dart';
import 'package:hacki/utils/utils.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.myUsername,
    required this.comment,
    required this.onStoryLinkTapped,
    required this.fetchMode,
    this.onReplyTapped,
    this.onMoreTapped,
    this.onEditTapped,
    this.onRightMoreTapped,
    this.opUsername,
    this.actionable = true,
    this.level = 0,
  });

  final String? myUsername;
  final String? opUsername;
  final Comment comment;
  final int level;
  final bool actionable;
  final void Function(Comment)? onReplyTapped;
  final void Function(Comment, Rect?)? onMoreTapped;
  final void Function(Comment)? onEditTapped;
  final void Function(Comment)? onRightMoreTapped;
  final void Function(String) onStoryLinkTapped;
  final FetchMode fetchMode;

  static final Map<int, Color> _colors = <int, Color>{};

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CollapseCubit>(
      key: ValueKey<String>('${comment.id}-BlocProvider'),
      lazy: false,
      create: (_) => CollapseCubit(
        commentId: comment.id,
        commentsCubit: context.tryRead<CommentsCubit>(),
        collapseCache: context.tryRead<CollapseCache>() ?? CollapseCache(),
      )..init(),
      child: BlocBuilder3<CollapseCubit, CollapseState, PreferenceCubit,
          PreferenceState, BlocklistCubit, BlocklistState>(
        builder: (
          BuildContext context,
          CollapseState state,
          PreferenceState prefState,
          BlocklistState blocklistState,
        ) {
          if (actionable && state.hidden) return const SizedBox.shrink();

          const Color orange = Color.fromRGBO(255, 152, 0, 1);
          final Color color = _getColor(level);

          final Padding child = Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Slidable(
                  startActionPane: actionable
                      ? ActionPane(
                          motion: const StretchMotion(),
                          children: <Widget>[
                            SlidableAction(
                              onPressed: (_) => onReplyTapped?.call(comment),
                              backgroundColor: Palette.orange,
                              foregroundColor: Palette.white,
                              icon: Icons.message,
                            ),
                            if (context.read<AuthBloc>().state.user.id ==
                                comment.by)
                              SlidableAction(
                                onPressed: (_) => onEditTapped?.call(comment),
                                backgroundColor: Palette.orange,
                                foregroundColor: Palette.white,
                                icon: Icons.edit,
                              ),
                            SlidableAction(
                              onPressed: (BuildContext context) =>
                                  onMoreTapped?.call(
                                comment,
                                context.rect,
                              ),
                              backgroundColor: Palette.orange,
                              foregroundColor: Palette.white,
                              icon: Icons.more_horiz,
                            ),
                          ],
                        )
                      : null,
                  endActionPane: actionable
                      ? ActionPane(
                          motion: const StretchMotion(),
                          children: <Widget>[
                            SlidableAction(
                              onPressed: (_) =>
                                  onRightMoreTapped?.call(comment),
                              backgroundColor: Palette.orange,
                              foregroundColor: Palette.white,
                              icon: Icons.av_timer,
                            ),
                          ],
                        )
                      : null,
                  child: InkWell(
                    onTap: () {
                      if (actionable) {
                        HapticFeedback.selectionClick();
                        context.read<CollapseCubit>().collapse();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Dimens.pt6,
                            right: Dimens.pt6,
                            top: Dimens.pt6,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                comment.by,
                                style: TextStyle(
                                  color: prefState.eyeCandyEnabled
                                      ? orange
                                      : color,
                                ),
                              ),
                              if (comment.by == opUsername)
                                const Text(
                                  ' - OP',
                                  style: TextStyle(
                                    color: orange,
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                comment.postedDate,
                                style: const TextStyle(
                                  color: Palette.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (actionable && state.collapsed)
                                CenteredText(
                                  text:
                                      '''collapsed (${state.collapsedCount + 1})''',
                                  color: Palette.orangeAccent,
                                )
                              else if (comment.deleted)
                                const CenteredText.deleted()
                              else if (comment.dead)
                                const CenteredText.dead()
                              else if (blocklistState.blocklist
                                  .contains(comment.by))
                                const CenteredText.blocked()
                              else
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: Dimens.pt8,
                                    right: Dimens.pt8,
                                    top: Dimens.pt6,
                                    bottom: Dimens.pt12,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: _CommentText(
                                      key: ValueKey<int>(comment.id),
                                      comment: comment,
                                      onLinkTapped: _onLinkTapped,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_shouldShowLoadButton(context))
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimens.pt12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        context.read<CommentsCubit>().loadMore(
                                              comment: comment,
                                            );
                                      },
                                      child: Text(
                                        '''Load ${comment.kids.length} ${comment.kids.length > 1 ? 'replies' : 'reply'}''',
                                        style: const TextStyle(
                                          fontSize: TextDimens.pt12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(
                          height: Dimens.zero,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          final double commentBackgroundColorOpacity =
              Theme.of(context).brightness == Brightness.dark ? 0.03 : 0.15;

          final Color commentColor = prefState.eyeCandyEnabled
              ? color.withOpacity(commentBackgroundColorOpacity)
              : Palette.transparent;
          final bool isMyComment = myUsername == comment.by;

          Widget wrapper = child;

          if (isMyComment && level == 0) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Palette.orange.withOpacity(0.2),
              ),
              child: wrapper,
            );
          }

          for (final int i in level.to(0, inclusive: false)) {
            final Color wrapperBorderColor = _getColor(i);
            final bool shouldHighlight = isMyComment && i == level;
            wrapper = Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(
                left: Dimens.pt8,
              ),
              decoration: BoxDecoration(
                border: i != 0
                    ? Border(
                        left: BorderSide(
                          color: wrapperBorderColor,
                        ),
                      )
                    : null,
                color: shouldHighlight
                    ? Palette.orange.withOpacity(0.2)
                    : commentColor,
              ),
              child: wrapper,
            );
          }

          return wrapper;
        },
      ),
    );
  }

  Color _getColor(int level) {
    final int initialLevel = level;
    if (_colors[initialLevel] != null) return _colors[initialLevel]!;

    while (level >= 10) {
      level = level - 10;
    }

    const int r = 255;
    int g = level * 40 < 255 ? 152 : (level * 20).clamp(0, 255);
    int b = (level * 40).clamp(0, 255);

    if (g == 255 && b == 255) {
      g = (level * 30 - 255).clamp(0, 255);
      b = (level * 40 - 255).clamp(0, 255);
    }

    final Color color = Color.fromRGBO(
      r,
      g,
      b,
      1,
    );

    _colors[initialLevel] = color;
    return color;
  }

  bool _shouldShowLoadButton(BuildContext context) {
    final CollapseState collapseState = context.read<CollapseCubit>().state;
    final CommentsState? commentsState =
        context.tryRead<CommentsCubit>()?.state;
    return fetchMode == FetchMode.lazy &&
        comment.kids.isNotEmpty &&
        collapseState.collapsed == false &&
        commentsState?.commentIds.contains(comment.kids.first) == false &&
        commentsState?.onlyShowTargetComment == false;
  }

  void _onLinkTapped(LinkableElement link) {
    if (link.url.isStoryLink) {
      onStoryLinkTapped.call(link.url);
    } else {
      LinkUtil.launch(link.url);
    }
  }
}

class _CommentText extends StatelessWidget {
  const _CommentText({
    super.key,
    required this.comment,
    required this.onLinkTapped,
  });

  final Comment comment;
  final void Function(LinkableElement) onLinkTapped;

  @override
  Widget build(BuildContext context) {
    final PreferenceState prefState = context.read<PreferenceCubit>().state;
    final TextStyle style = TextStyle(
      fontSize: prefState.fontSize.fontSize,
    );
    final TextStyle linkStyle = TextStyle(
      fontSize: prefState.fontSize.fontSize,
      decoration: TextDecoration.underline,
      color: Palette.orange,
    );
    if (comment is BuildableComment) {
      return SelectableText.rich(
        buildTextSpan(
          (comment as BuildableComment).elements,
          style: style,
          linkStyle: linkStyle,
          onOpen: onLinkTapped,
        ),
        onTap: () => onTextTapped(context),
      );
    } else {
      return SelectableLinkify(
        text: comment.text,
        style: style,
        linkStyle: linkStyle,
        onOpen: onLinkTapped,
        onTap: () => onTextTapped(context),
      );
    }
  }

  void onTextTapped(BuildContext context) {
    if (context.read<PreferenceCubit>().state.tapAnywhereToCollapseEnabled) {
      HapticFeedback.selectionClick();
      context.read<CollapseCubit>().collapse();
    }
  }
}
