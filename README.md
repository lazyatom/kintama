Hello
=====

This is a tool for testing code. Or maybe it's a tool for exploring ways to test code. See below.

Huh? Really? Another one?
====

... Yeah, I know. To be honest, I'm not 100% sure why I'm doing this. Here are some guesses though:

My testing tools of choice, at the moment, are [Test::Unit][] with [shoulda][] to provide nested contexts, but not really it's macros.

I'm not a huge fan of [Test::Unit][]. Whenever I've tried to extend its behaviour I've hit snags, and found its code difficult to understand (particularly as lots of it don't seem to be regularly used - I'm looking at you, [TkRunner][] and friends). I also don't really love [RSpec][], but I think that's just a personal preference (I learned with test/unit, and I didn't want to relearn all of the matcher stuff).

I like [shoulda][], because like [RSpec][], it lets me nest groups of tests in ways that help remove duplication in setups. However, [I don't have a lot of confidence that shoulda is going to stick around in its current, useful-for-stuff-that-isnt-RSpec form](http://robots.thoughtbot.com/post/701863189/shoulda-rails3-and-beyond).

I like some of the more verbose output that [Cucumber][] and [RSpec][] produce, but as I mentioned above, I don't care for [RSpec][]'s matcher-heavy syntax. It's basically impossible to reproduce that output on anything that uses [Test::Unit][] as a base (see [MonkeySpecDoc][] for an example, which fails because it cannot support any more than one level of nesting)

I also like things like [`before(:all)`][before_all], and [`fast_context`][fast_context], but don't like having to hack around inside [Test::Unit][] to implement them (I already have with [`test_startup`][test_startup]; it works but who knows for how long).


Related work
------------

In the spirit of [shoulda][], a small library called [context][] adds the simple nested context structures to [Test::Unit][], but that's the problem - we can't build anything on top of [Test::Unit][].

Ditto for [contest][].

Probably the closest thing I've seen is [baretest][]. If you look around the code, some of the implementation details are quite similar to those that have evolved in this code (context-ish objects with parents). However, in many ways baretest is more complex, and the final API that it provides is quite foreign compared to [shoulda][].

Another alternative test framework is [riot][], which claims to be fast, but also appears to constrain the way that tests are written by avoiding instance variables in setups, for example.

[Testy][] is interesting - it looks like its output is YAML!. [Tryouts][] is thinking outside the box, using comment examples.

[Zebra][] addresses the apparent duplication of the test name and the test body, but does it by introducing an [RSpec][]-esque method on every object. Wild. Also, it's an extension of [Test::Unit][], so that's strike two for me, personally.

I have no idea what to make of [Shindo][].

[Exemplor][]... oh my god why am I contributing to this mess.

Erm.

Exploring future testing
------------------------

I wanted to explore how easy it would be to reproduce a test framework with a modern, [shoulda][]/RSpec-esque syntax, but that was simple enough to be understandable when anyone needed to change it.

I also wanted to be able to start exploring different ways of expressing test behaviour, outside of the classic `setup -> test -> teardown` cycle, but didn't feel that I could use test/unit as a basis for this kind of speculative work without entering a world of pain.

Hence... _this_.


Examples
========

These will all be very familiar to most people who are already users of [shoulda][]:

    require 'kintama'

    context "A thing" do
      setup do
        @thing = Thing.new
      end
      should "act like a thing" do
        assert_equal "thingish", @thing.nature
      end
    end

Simple, right? Note that we don't need an outer subclass of `Test::Unit::TestCase`; it's nice to lose that noise, but otherwise so far so same-old-same-old. That's kind-of the point. Anyway, here's what you get when you run this:

    A thing
      should act like a thing: F

    1 tests, 1 failures

    1) A thing should act like a thing:
      uninitialized constant Thing (at ./examples/simple.rb:6)

Firstly, it's formatted nicely. There are no cryptic line numbers or `bind` references like [shoulda][]. If you run it from a terminal, you'll get colour output too. That's nice.


Aliases
----

There are a bunch of aliases you can use in various ways. If you don't like:

    context "A thing" do

you could also write:

    describe Thing do # like RSpec! ...
    given "a thing" do # ...
    testcase "a thing" do # ...

It's trivial to define other aliases that might make your tests more readable. Similarly for defining the tests themselves, instead of:

    should "act like a thing" do

you might prefer:

    it "should act like a thing" do # ...
    test "acts like a thing" do # ...

Sometimes just having that flexibility makes all the difference.


Setup, teardown, nested contexts
--------------

These work as you'd expect based on shoulda or RSpec:

    given "a Thing" do
      setup do
        @thing = Thing.new
      end

      it "should be happy" do
        assert @thing.happy?
      end

      context "that is prodded" do
        setup do
          @thing.prod!
        end

        should "not be happy" do
          assert_false @thing.happy?
        end
      end

      teardown do
        @thing.cleanup_or_something
      end
    end

You can also add (several) global `setup` and `teardown` blocks, which will be run before (or after) every test. For example:

    Kintama.setup do
      @app = ThingApp.new
    end

    given "a request" do
      it "should work" do
        assert_equal 200, @app.response.status
      end
    end


Helpers
-------

If you want to make methods available in your tests, you have a few options. You can define them inline:

    context "my face" do
      should "be awesome" do
        assert_equal "awesome", create_face.status
      end

      helpers do
        def create_face
          Face.new(:name => "james", :eyes => "blue", :something => "something else")
        end
      end
    end

Ideally I would've liked to make this syntatically similar to defining a private method in a class, but for various reasons that was not possible. Anyway, your other options are including a module:

    module FaceHelper
      def create_face
        # etc ...
      end
    end

    context "my face" do
      include FaceHelper
      should "be awesome" do
        assert_equal "awesome", create_face.status
      end
    end

Or, if you're going to use the method in all your tests, you can add the module globally:

    Kintama.add FaceHelper

or just define the method globally:

    Kintama.add do
      def create_face
        # etc ...
      end
    end

### Aside: what happens if you do define a method in the context?

It becomes available within context (and subcontext) definitions. Here's an example:

    context "blah" do
      def generate_tests_for(thing)
        it "should work with #{thing}" do
          assert thing.works
        end
      end

      [Monkey.new, Tiger.new].each do |t|
        generate_tests_for(t)
      end
    end

This is a bit like defining a 'class method' in a `TestCase` and then being able to call it to generate contexts or tests within that `TestCase`. It's not that tricky once you get used to it.


And now, the more experimental stuff
====================================

Wouldn't it be nice to be able to introspect a failed test without having to re-run it? Well, you can. Lets imagine this test:

    context "A thing" do
      setup do
        @thing = Thing.new
      end
      should "act like a thing" do
        assert_equal "thingish", @thing.nature
      end
    end

Well... TO BE CONTINUED.



[Test::Unit]: http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/
[TkRunner]: http://ruby-doc.org/stdlib/libdoc/test/unit/rdoc/classes/Test/Unit/UI/Tk/TestRunner.html
[RSpec]: http://rspec.info
[Cucumber]: http://cukes.info
[MonkeySpecDoc]: http://jgre.org/2008/09/03/monkeyspecdoc/
[before_all]: http://rspec.info/documentation/
[fast_context]: https://github.com/lifo/fast_context
[test_startup]: https://github.com/freerange/test_startup
[shoulda]: https://github.com/thoughtbot/shoulda
[baretest]: https://github.com/apeiros/baretest
[riot]: https://github.com/thumblemonks/riot
[context]: https://github.com/jm/context
[contest]: https://github.com/citrusbyte/contest
[Testy]: https://github.com/ahoward/testy
[Tryouts]: https://github.com/delano/tryouts
[Zebra]: https://github.com/jamesgolick/zebra
[Shindo]: https://github.com/geemus/shindo
[Exemplor]: https://github.com/quackingduck/exemplor