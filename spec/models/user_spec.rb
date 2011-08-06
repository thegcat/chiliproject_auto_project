require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  subject {lambda {user.save}}

  describe "when an exisiting user is updated" do
    let(:user) {Factory.create :user}

    describe "with no status change" do
      it "should not change the user's projects" do
        subject.should_not change user, :projects
      end
    end

    describe "with a status change to active" do
      before do
        user.status = User::STATUS_ACTIVE
      end

      describe "from registered" do
        let(:user) {Factory.create :user, :status => User::STATUS_REGISTERED}

        describe "if a project with the same identifier as the user's login doesn't exist yet" do
          it "should add the user to the project" do
            subject.should change(user.projects, :count).by(1)
          end
        end

        describe "if a project with the same identifier as the user's login already exists" do
          it "should not change the user's projects" do
            subject.should_not change user, :projects
          end
        end
      end

      describe "from locked" do
        let(:user) {Factory.create :user, :status => User::STATUS_LOCKED}

        it "should not change the user's projects" do
          subject.should_not change user, :projects
        end
      end
    end
  end

  describe "when a new user is created" do
    let(:user) {Factory.build :user, :status => nil}

    describe "with an active status" do
      before do
        user.status = User::STATUS_ACTIVE
      end

      describe "if a project with the same identifier as the user's login doesn't exist yet" do
        it "should add the user to the project" do
          subject.should change(user.projects, :count).by(1)
        end
      end

      describe "if a project with the same identifier as the user's login already exists" do
        it "should not change the user's projects" do
          subject.should_not change user, :projects
        end
      end
    end
    
    describe "with an registered status" do
      before do
        user.status = User::STATUS_REGISTERED
      end
      
      it "should not change the user's projects" do
        subject.should_not change user, :projects
      end
    end
  end
end