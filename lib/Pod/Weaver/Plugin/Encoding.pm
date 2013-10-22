package Pod::Weaver::Plugin::Encoding;
# ABSTRACT: Add an encoding command to your POD

use Moose;
use Moose::Autobox;
use List::AllUtils 'any';
use MooseX::Types::Moose qw(Str);
use aliased 'Pod::Elemental::Node';
use aliased 'Pod::Elemental::Element::Pod5::Command';
use namespace::autoclean -also => 'find_encoding_command';

with 'Pod::Weaver::Role::Finalizer';

=head1 SYNOPSIS

In your weaver.ini:

  [-Encoding]

or

  [-Encoding]
  encoding = kio8-r

=head1 DESCRIPTION

This section will add an C<=encoding> command like

  =encoding utf-8

to your POD.

=attr encoding

The encoding to declare in the C<=encoding> command. Defaults to
C<utf-8>.

=cut

has encoding => (
    is      => 'ro',
    isa     => Str,
    default => 'UTF-8',
);

=method finalize_document

This method prepends an C<=encoding> command with the content of the
C<encoding> attribute's value to the document's children.

Does nothing if the document already has an C<=encoding> command.

=cut

sub finalize_document {
    my ($self, $document) = @_;

    return if find_encoding_command($document->children);

    $document->children->unshift(
        Command->new({
            command => 'encoding',
            content => $self->encoding,
        }),
    );
}

sub find_encoding_command {
    my ($children) = @_;
    return $children->grep(sub {
        return 1 if $_->isa(Command) && $_->command eq 'encoding';
        return 0 unless $_->does(Node);
        return any { find_encoding_command($_->children) };
    })->length;
}

=head1 SEE ALSO

L<Pod::Weaver::Section::Encoding> is very similar to this module, but
expects the encoding to be specified in a special comment within the
document that's being woven.

=cut

__PACKAGE__->meta->make_immutable;

1;
