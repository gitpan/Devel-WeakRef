use mods q{
  Devel::WeakRef;
  Test::Helper;
};

my %cnt;
{
  package Foo;
  sub new {
    my ($class, $key)=@_;
    $cnt{$key}++;
    bless \$key, $class;
  }
  sub DESTROY {
    my ($self)=@_;
    my $key=$$self;
    $cnt{$key}--;
  }
  sub action {
    my ($self)=@_;
    $$self * $$self;
  }
}

test {
  comm 'Creating $foo';
  my $foo=new Foo 3;
  ok $foo;
  ok +($cnt{3}==1);
  ok +($foo->action == 9);
  comm "\$foo is $foo";

  comm 'Creating weak ref';
  my $foo_=new Devel::WeakRef $foo;
  ok +($cnt{3}==1);
  ok $foo_;
  ok +($foo eq $foo_->deref);
  comm "\$foo_ is $foo_ (ref to " . $foo_->deref . ')';

  comm 'Using weak ref';
  ok +($foo_->deref->action == 9);
  ok not $foo_->empty;

  comm 'Killing strong ref';
  $foo=17;
  ok +($cnt{3}==0);
  ok defined $foo_;
  ok not defined $foo_->deref;
  ok +$foo_->empty;
  comm "\$foo_->deref is " . $foo_->deref if defined $foo_->deref;

  comm 'Killing weak ref';
  $foo_=19;
  ok +($cnt{3}==0);

  comm 'Creating $bar';
  my $bar=new Foo 2;
  ok +($cnt{2}==1);

  comm 'Creating weak ref 1';
  my $bar_1=new Devel::WeakRef $bar;
  ok +($cnt{2}==1);
  ok +($bar eq $bar_1->deref);

  comm 'Creating weak ref 2';
  my $bar_2=new Devel::WeakRef $bar;
  ok +($cnt{2}==1);
  ok +($bar eq $bar_1->deref);
  ok +($bar eq $bar_2->deref);

  comm 'Using weak refs';
  ok +($bar_1->deref->action == 4);
  ok +($bar_2->deref->action == 4);

  comm 'Killing strong ref';
  $bar=15;
  ok +($cnt{2}==0);
  ok not defined $bar_1->deref;
  ok not defined $bar_2->deref;

  comm 'Killing weak ref 1';
  $bar_1=13;
  ok +($cnt{2}==0);
  ok not defined $bar_2->deref;

  comm 'Killing weak ref 2';
  $bar_2=11;
  ok +($cnt{2}==0);

  comm 'Creating $baz';
  my $baz=new Foo 4;

  comm 'Creating weak ref';
  my $baz_=new Devel::WeakRef $baz;
  ok +($cnt{4}==1);

  comm 'Using weak ref';
  ok +($baz_->deref->action == 16);

  comm 'Killing weak ref';
  $baz_=9;

  comm 'Using strong ref';
  ok +($baz->action == 16);
  ok +($cnt{4}==1);

  comm 'Killing strong ref';
  $baz=77;
  ok +($cnt{4}==0);

  comm 'Making sure reference arg is ensured';
  ok not runs {new Devel::WeakRef 17};

  comm 'Creating hash ref $quux';
  my $quux={a => 41};

  comm 'Creating weak ref';
  my $quux_=new Devel::WeakRef $quux;

  comm 'Using weak ref';
  ok +($quux_->deref->{a} == 41);

  comm 'Killing strong ref';
  $quux=75;
  ok not defined $quux_->deref;
};
