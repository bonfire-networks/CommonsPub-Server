echo "This script helps merge upstream updates while preserving local customisations"

echo "Check out our MoodleNet branch"
git checkout flavour/moodlenet

echo "Pull changes from upstream"
git pull https://gitlab.com/moodlenet/backend.git develop 

echo "Copy upstream changes to our MoodleNet branch"
git push

echo "Check out flavour/commonspub branch"
git checkout flavour/commonspub

echo "Merge MoodleNet to CommonsPub, without commiting yet"
git merge --no-ff --no-commit flavour/moodlenet

echo "Restore files which we don't want overwritten (add any core files that should be different in CommonsPub to the below line in the script)"
for file in cpub-merge-from-upstream.sh cpub-merge-from-branch.sh README.md DEPLOY.md HACKING.md config/docker.env config/docker.dev.env Makefile docker-compose.yml docker-compose.pi.yml .gitlab-ci.yml
do
    git reset HEAD ${file}
    git checkout -- ${file}
done

echo "Please check if everything looks good (including resolving any merge conflicts) before continuing. Press 'c' to merge and push the changes, or just enter to abort."
read answer
if echo "$answer" | grep -iq "^c" ; then
    echo "Merging and pushing..."
    git commit -m "merged from upstream"
    git push
else 
    echo "Aborting the merge."
    git merge --abort
    exit 1
fi