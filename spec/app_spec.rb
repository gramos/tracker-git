require 'spec_helper'
require 'tracker_git'

describe TrackerGit::App do
  describe '@main_block' do
    let(:app) { TrackerGit::App }
    let(:main_block) { app.main_block }

    before do
      PivotalTracker::Project.stub(:find).and_return(stub.as_null_object)
    end

    describe '.deliverer' do
      let(:git) { stub.as_null_object }
      let(:project) { stub.as_null_object }

      before do
        TrackerGit::Git.stub(:new).and_return(git)
        TrackerGit::Project.stub(:new).and_return(project)
        TrackerGit::Deliverer.any_instance.should_receive(:mark_as_delivered)
        main_block.call
      end

      subject { app.deliverer }
      its(:git) { should == git }
      its(:project) { should == project }
    end

    describe '.git' do
      subject { app.git }

      context 'when --no-branch is not set' do
        before do
          TrackerGit::App.stub(:options).and_return({})
          main_block.call
        end

        its(:branch) { should == 'master' }
      end

      context 'when --no-branch is set' do
        before do
          TrackerGit::App.stub(:options).and_return('current-branch' => true)
          main_block.call
        end

        its(:branch) { should be_nil }
      end
    end

    describe '.project' do
      let(:id) { stub }
      let(:token) { stub}
      let(:env) do
        {
          'TRACKER_PROJECT_ID' => id,
          'TRACKER_TOKEN' => token
        }
      end

      before do
        stub_const('ENV', env)
        main_block.call
      end

      subject { app.project }
      its(:project_id) { should == id }
      its(:api_token) { should == token }
    end
  end
end