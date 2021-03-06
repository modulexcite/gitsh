require 'spec_helper'

describe 'Chaining methods' do
  describe 'And' do
    it 'runs init and status' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init && status')
        expect(gitsh).to output /nothing to commit/
      end
    end

    it 'runs fetch, fails, and short circuits' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type('fetch origin && status')
        expect(gitsh).to_not output /nothing to commit/
      end
    end

    it 'sets a git config variable and reads it back out' do
      GitshRunner.interactive do |gitsh|
        gitsh.type(':set test.setting hello && config test.setting')
        expect(gitsh).to output 'hello'
      end
    end

    it 'sets a variable and reads it back out' do
      GitshRunner.interactive do |gitsh|
        gitsh.type(':set test hello && :echo $test')
        expect(gitsh).to output 'hello'
      end
    end
  end

  describe 'Or' do
    it 'runs init then short circuits' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init || status')
        expect(gitsh).to_not output /nothing to commit/
      end
    end

    it 'runs fetch, fails, then runs status' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init')
        gitsh.type('fetch origin || status')
        expect(gitsh).to output /nothing to commit/
      end
    end

    it 'executes the second command if the first encounters an error' do
      GitshRunner.interactive do |gitsh|
        gitsh.type(':set name George')
        gitsh.type(':echo $user_name || :echo $name')

        expect(gitsh).to output_error /user_name/
        expect(gitsh).to output /George/
      end
    end
  end

  describe 'Multi' do
    it 'runs init, passes, runs fetch, fails, then runs status, and passes' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init; fetch origin; status')
        expect(gitsh).to output /Initialized empty Git repository/
        expect(gitsh).to output_error /Could not read from remote repository/
        expect(gitsh).to output /nothing to commit/
      end
    end

    it 'allows the right hand side to be blank' do
      GitshRunner.interactive do |gitsh|
        gitsh.type('init;')
        expect(gitsh).to output_no_errors
        expect(gitsh).to output /Initialized/
      end
    end
  end
end
