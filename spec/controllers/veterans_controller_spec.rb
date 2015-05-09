require "rails_helper"

describe VeteransController do
  describe "#new" do
    it "makes a new record" do
      get :new
      expect(assigns(:veteran)).to be_new_record
    end

    it "renders the #new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "#create" do
    let(:veteran_params) do
      {
        email: "billybob@email.com",
        first_name: "Billy",
        last_name: "Bob"
      }
    end

    let(:new_veteran) { Veteran.new(veteran_params) }

    before do
      allow(Veteran).to receive(:new).and_return(new_veteran)
    end

    it "makes a new record with the params" do
      expect(Veteran).to receive(:new).with(veteran_params).and_return(new_veteran)
      post :create, veteran: veteran_params, format: :html
    end

    context "when the record saves successfully" do
      describe "#html" do
        it "redirects to the action_path" do
          post :create, veteran: veteran_params, format: :html
          expect(response).to redirect_to(action_path)
        end

        it "shows a notice" do
          post :create, veteran: veteran_params, format: :html
          expect(flash[:notice]).to include('Thanks for signing up!')
        end

        it "sends a wecome email" do
          user_mailer_double = double(UserMailer, welcome: "<h1>A Mailer</h1>")
          allow(UserMailer).to receive(:welcome).and_return(user_mailer_double)

          expect(user_mailer_double).to receive(:deliver).and_return(true)

          post :create, veteran: veteran_params, format: :html
        end
      end

      describe "#json" do
        it "renders the show view" do
          post :create, veteran: veteran_params, format: :json
          expect(response).to render_template(:show)
        end
      end
    end

    context "when the record does not save successfully" do
      before do
        allow(new_veteran).to receive(:save).and_return(false)
      end

      describe "#html" do
        it "does not send the welcome email" do
          expect(UserMailer).to_not receive(:welcome)
          post :create, veteran: veteran_params, format: :html
        end

        it "renders the new template" do
          post :create, veteran: veteran_params, format: :html
          expect(response).to render_template(:new)
        end
      end

      describe "#json" do
        it "renders the errors" do
          allow(new_veteran).to receive(:errors).and_return("ERRORZ")

          post :create, veteran: veteran_params, format: :json
          expect(response.body).to include("ERRORZ")
        end
      end
    end
  end
end
