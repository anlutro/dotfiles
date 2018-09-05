use strict;
use warnings;
use Irssi;

sub msg_rewrite_fromgitter_messages {
    my ($server, $data, $nick, $nick_and_address) = @_;
    return unless $nick eq "FromGitter";

    my ($target, $message) = split /:/, $data, 2;
    my $match = $message =~ m/^\x02\<([^>]+)\>\s*[\x02\x0f]\s*(.*)$/;
    return unless $match;
    my ($gitter_nick, $new_message) = ($1, $2);

    Irssi::signal_continue($server, "$target:$new_message", "Gitter:$gitter_nick", $nick_and_address);
}

Irssi::signal_add('event privmsg', 'msg_rewrite_fromgitter_messages');
