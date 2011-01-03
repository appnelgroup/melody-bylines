package Melody::Bylines;
use strict;
use warnings;

#--- transformer handlers

sub add_byline_field {
    my ( $eh, $app, $param, $tmpl ) = @_;
    return unless $tmpl->isa('MT::Template');
    my $q = $app->can('query') ? $app->query : $app->param;
    my $model = $q->param('_type') ? 'page' : 'entry'; # assuming mode == view
    my $byline = '';
    if ( my $id = $q->param('id') ) {
        require MT::Util;
        my $obj = $app->model($model)->load( $id, { cached_ok => 1 } );
        $byline = MT::Util::encode_html( $obj->byline )
          if $obj && $obj->byline;
    }
    my $innerHTML
      = qq{ <textarea name="byline" id="byline" class="full-width short" cols="" rows="" mt:watch-change="1">$byline</textarea> };
    my $host_node 
      = $tmpl->getElementById('tags-field')
      or $tmpl->getElementById('text-field')
      or return $app->error('getElementById failed');
    my $block_node = $tmpl->createElement( 'app:setting',
                                      { id => 'byline', label => 'byline' } );
    $block_node->innerHTML($innerHTML);
    return $tmpl->insertBefore( $block_node, $host_node )
      or $app->error('failed to insertBefore');
} ## end sub add_byline_field

sub save_byline {
    my ( $eh, $app, $obj, $orig ) = @_;
    my $q = $app->can('query') ? $app->query : $app->param;
    my $byline = $q->param('byline') || '';
    $obj->byline($byline);
}

#--- template tag handlers

sub byline {
    my ( $ctx, $args, $cond ) = @_;
    my $entry  = $ctx->stash('entry');
    my $author = $ctx->stash('author');
    return $ctx->_no_author_error unless $entry || $author;
    return
         $entry
      && $entry->byline  ? $entry->byline  : $author
      && $author->byline ? $author->byline : '';
}

1;
