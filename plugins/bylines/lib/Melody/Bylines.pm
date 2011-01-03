package Melody::Bylines;
use strict;
use warnings;

#--- transformer handlers

sub add_byline_field {
    my ( $eh, $app, $param, $tmpl ) = @_;
    return unless $tmpl->isa('MT::Template');
    my $q = $app->can('query') ? $app->query : $app->param;
    my $model
      = $q->param('_type') eq 'author'
      ? 'author'
      : 'entry';    # too presumptuous? die instead?
    my $byline = '';
    if ( my $id = $q->param('id') ) {
        require MT::Util;
        my $obj = $app->model($model)->load( $id, { cached_ok => 1 } );
        $byline = MT::Util::encode_html( $obj->byline )
          if $obj && $obj->byline;
    }
    my $innerHTML;
    my $host_node;
    if ( $model eq 'author' ) {
        $innerHTML = qq{ 
    	<div class="textarea-wrapper">
      		<textarea name="byline" id="byline" class="full-width" mt:watch-change="1">$byline</textarea>
      	</div>	
      };
        $host_node = $tmpl->getElementById('url-field');
    }
    else {
        $innerHTML
          = qq{ <textarea name="byline" id="byline" class="full-width short" cols="" rows="" mt:watch-change="1">$byline</textarea> };
        $host_node = $tmpl->getElementById('tags-field')
          || $tmpl->getElementById('text-field');
    }
    return $app->error('getElementById failed') unless $host_node;
    my $block_node = $tmpl->createElement( 'app:setting',
                                       { id => 'byline', label => 'byline' } )
      ;    # need hint
    $block_node->innerHTML($innerHTML);
    return $tmpl->insertAfter( $block_node, $host_node )
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
    if ( my $entry = $ctx->stash('entry') ) {
        if ( $entry->byline ) {    # assume no 0 value
            return $entry->byline;
        }
        elsif ( my $author = $entry->author ) {
            return $author->byline;
        }
    }
    if ( my $author = $ctx->stash('author') ) {
        return $author->byline || '';
    }
    return $ctx->_no_author_error;
}

1;
