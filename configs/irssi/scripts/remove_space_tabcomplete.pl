Irssi::signal_add_first('complete word' => sub {
	&Irssi::signal_continue;
	${$_[4]} = 0
})
