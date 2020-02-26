use strict;
use warnings;
package Time::Tiny;
# ABSTRACT: A time object, with as little code as possible

our $VERSION = '1.09';

use overload 'bool' => sub () { 1 };
use overload '""'   => 'as_string';
use overload 'eq'   => sub { "$_[0]" eq "$_[1]" };
use overload 'ne'   => sub { "$_[0]" ne "$_[1]" };





#####################################################################
# Constructor and Accessors

=pod

=method new

  # Create a Time::Tiny object for midnight
  my $midnight = Time::Tiny->new(
      hour   => 0,
      minute => 0,
      second => 0,
  );

The C<new> constructor creates a new B<Time::Tiny> object.

It takes three named parameters. C<hour> should be the hour of the day (0-23),
C<minute> should be the minute of the hour (0-59), and C<second> should be
the second of the minute (0-59).

These are the only parameters accepted.

Returns a new B<Time::Tiny> object.

=cut

sub new {
	my $class = shift;
	bless { @_ }, $class;
}

=pod

=method now

  my $current_time = Time::Tiny->now;

The C<now> method creates a new date object for the current time.

The time created will be based on localtime, despite the fact that
the time is created in the floating time zone.

This means that the time created by C<now> is somewhat lossy, but
since the primary purpose of B<Time::Tiny> is for small transient
time objects, and B<not> for use in calculations and comparisons,
this is considered acceptable for now.

Returns a new B<Time::Tiny> object.

=cut

sub now {
	my @t = localtime time;
	$_[0]->new(
		hour   => $t[2],
		minute => $t[1],
		second => $t[0],
	);
}

=pod

=method hour

The C<hour> accessor returns the hour component of the time as
an integer from zero to twenty-three (0-23) in line with 24-hour
time.

=cut

sub hour {
	$_[0]->{hour} || 0;
}

=pod

=method minute

The C<minute> accessor returns the minute component of the time
as an integer from zero to fifty-nine (0-59).

=cut

sub minute {
	$_[0]->{minute} || 0;
}

=pod

=method second

The C<second> accessor returns the second component of the time
as an integer from zero to fifty-nine (0-59).

=cut

sub second {
	$_[0]->{second} || 0;
}





#####################################################################
# Type Conversion

=pod

=method from_string

The C<from_string> method creates a new B<Time::Tiny> object from a string.

The string is expected to be an "hh:mm:ss" type ISO 8601 time string.

  my $almost_midnight = Time::Tiny->from_string( '23:59:59' );

Returns a new B<Time::Tiny> object, or throws an exception on error.

=cut

sub from_string {
	my $string = $_[1];
	unless ( defined $string and ! ref $string ) {
		require Carp;
		Carp::croak("Did not provide a string to from_string");
	}
	unless ( $string =~ /^(\d\d):(\d\d):(\d\d)$/ ) {
		require Carp;
		Carp::croak("Invalid time format (does not match ISO 8601 hh:mm:ss)");
	}
	$_[0]->new(
		hour   => $1 + 0,
		minute => $2 + 0,
		second => $3 + 0,
	);
}

=pod

=method as_string

The C<as_string> method converts the time object to an ISO 8601
time string, with separators (see example in C<from_string>).

Returns a string.

=cut

sub as_string {
	sprintf( "%02u:%02u:%02u",
		$_[0]->hour,
		$_[0]->minute,
		$_[0]->second,
	);
}

=pod

=method DateTime

The C<DateTime> method is used to create a L<DateTime> object
that is equivalent to the B<Time::Tiny> object, for use in
conversions and calculations.

As mentioned earlier, the object will be set to the 'C' locate,
and the 'floating' time zone.

If installed, the L<DateTime> module will be loaded automatically.

Returns a L<DateTime> object, or throws an exception if L<DateTime>
is not installed on the current host.

=cut

sub DateTime {
	require DateTime;
	my $self = shift;
	DateTime->new(
		year      => 1970,
		month     => 1,
		day       => 1,	
		hour      => $self->hour,
		minute    => $self->minute,
		second    => $self->second,
		locale    => 'C',
		time_zone => 'floating',
		@_,
	);
}

1;

__END__

=pod

=head1 SYNOPSIS

  # Create a time manually
  $christmas = Time::Tiny->new(
      hour   => 10,
      minute => 45,
      second => 0,
      );
  
  # Show the current time
  $now = Time::Tiny->now;
  print "Hour   : " . $now->hour   . "\n";
  print "Minute : " . $now->minute . "\n";
  print "Second : " . $now->second . "\n";

=head1 DESCRIPTION

B<Time::Tiny> is a member of the L<DateTime::Tiny> suite of time modules.

It implements an extremely lightweight object that represents a time,
without any date data.

=head2 The Tiny Mandate

Many CPAN modules which provide the best implementation of a concept
can be very large. For some reason, this generally seems to be about
3 megabyte of ram usage to load the module.

For a lot of the situations in which these large and comprehensive
implementations exist, some people will only need a small fraction of the
functionality, or only need this functionality in an ancillary role.

The aim of the Tiny modules is to implement an alternative to the large
module that implements a subset of the functionality, using as little
code as possible.

Typically, this means a module that implements between 50% and 80% of
the features of the larger module, but using only 100 kilobytes of code,
which is about 1/30th of the larger module.

=head2 The Concept of Tiny Date and Time

Due to the inherent complexity, Date and Time is intrinsically very
difficult to implement properly.

The arguably B<only> module to implement it completely correct is
L<DateTime>. However, to implement it properly L<DateTime> is quite slow
and requires 3-4 megabytes of memory to load.

The challenge in implementing a Tiny equivalent to DateTime is to do so
without making the functionality critically flawed, and to carefully
select the subset of functionality to implement.

If you look at where the main complexity and cost exists, you will find
that it is relatively cheap to represent a date or time as an object,
but much much more expensive to modify or convert the object.

As a result, B<Time::Tiny> provides the functionality required to
represent a date as an object, to stringify the date and to parse it
back in, but does B<not> allow you to modify the dates.

The purpose of this is to allow for date object representations in
situations like log parsing and fast real-time work.

The problem with this is that having no ability to modify date limits
the usefulness greatly.

To make up for this, B<if> you have L<DateTime> installed, any
B<Time::Tiny> module can be inflated into the equivalent L<DateTime>
as needed, loading L<DateTime> on the fly if necessary.

For the purposes of date/time logic, all B<Time::Tiny> objects exist
in the "C" locale, and the "floating" time zone (although obviously in a
pure date context, the time zone largely doesn't matter).

When converting up to full L<DateTime> objects, these locale and time
zone settings will be applied (although an ability is provided to
override this).

In addition, the implementation is strictly correct and is intended to
be very easily to sub-class for specific purposes of your own.

=head1 USAGE

In general, the intent is that the API be as close as possible to the
API for L<DateTime>. Except, of course, that this module implements
less of it.

=head1 HISTORY

This module was written by Adam Kennedy in 2006.  In 2016, David Golden
adopted it as a caretaker maintainer.

=head1 SEE ALSO

L<DateTime>, L<DateTime::Tiny>, L<Time::Tiny>, L<Config::Tiny>, L<ali.as>

=cut
